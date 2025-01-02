#!/usr/bin/env xonsh

import os
import socket
import sys
import subprocess
import traceback
import time
import re
import requests
import argparse
import xonsh

import server
import client
import util

$RAISE_SUBPROC_ERROR = True
$XONSH_SHOW_TRACEBACK = True

wisp_port = 6001
echo_port = 6002
server_timeout = 5
test_duration = 10
print_md = False

echo_dir = util.base_path / "echo"
echo_repo = echo_dir / "tokio"

def install_echo():
  mkdir -p @(echo_dir)
  if echo_repo.exists():
    return
  git clone "https://github.com/tokio-rs/tokio" @(echo_repo)
  with util.temp_cd(echo_repo):
    cargo build --release --example echo

def run_echo():
  with util.temp_cd(echo_repo):
    cargo run --release --example echo 127.0.0.1:@(echo_port) 2>&1 >/dev/null &
    return util.last_job()

def wait_for_server():
  for i in range(0, int(server_timeout / 2)):
    try:
      requests.get(f"http://127.0.0.1:{wisp_port}/", timeout=0.5).text
      break
    except:
      time.sleep(0.5)
  else:
    raise RuntimeError("Server failed to start in time.")

def wait_for_socket():
  for i in range(0, int(server_timeout / 2)):
    s = socket.socket()
    try:
      s.connect(("127.0.0.1", echo_port)) 
      s.close()
      break
    except:
      time.sleep(0.5)
  else:
    raise RuntimeError("Echo server failed to start in time.")

def print_table(table, print_md):
  corner_separator = "-|-" if print_md else "-+-"
  col_widths = []
  for x, col in enumerate(table[0]):
    col_widths.append(0)
    for y in range(len(table)):
      col_widths[-1] = max(col_widths[-1], len(table[y][x]))

  rows = []
  for row in table:
    cells = [cell.ljust(col_widths[x]) for x, cell in enumerate(row)]
    row = " | ".join(cells)
    if print_md:
      row = f"| {row} |"
    rows.append(row)

  row_separator = corner_separator.join(["-" * w for w in col_widths]) + "-"
  if print_md:
    row_separator = f"|-{row_separator}|"

  if print_md:
    table_str = f"\n{row_separator}\n".join(rows[:2])
    table_str += "\n" + "\n".join(rows[2:])
  else:
    table_str = f"\n{row_separator}\n".join(rows)

  print(table_str)

def main():
  sudo true
  install_echo()
  echo_process = run_echo()
  wait_for_socket()

  for implementation in server.implementations + client.implementations:
    if implementation.is_installed():
      continue
    print(f"installing {implementation.name}")
    implementation.install()
  
  log_dir = util.base_path / "log"
  mkdir -p @(log_dir)

  table = [[""] + [impl.name for impl in client.implementations]]
  client_job = None
  server_job = None

  for server_impl in server.implementations:
    table.append([server_impl.name])
    for client_impl in client.implementations:
      print(f"testing {server_impl.name} with {client_impl.name}")
      server_log_file = log_dir / f"SERVER_{server_impl.name}_{client_impl.name}.log"
      client_log_file = log_dir / f"CLIENT_{server_impl.name}_{client_impl.name}.log"
      
      try:
        print("starting server")
        util.kill_by_port(wisp_port)
        server_job = server_impl.run(wisp_port, server_log_file)
        wait_for_server()

        print("running client and recording speeds...")
        client_jobs = client_impl.run(wisp_port, echo_port, client_log_file)

        time.sleep(1)
        speed = util.measure_bandwidth(echo_port, test_duration)
        result = f"{round(speed / (1024 ** 2), 2)} MiB/s"
        print(f"result: {result}")

      except (subprocess.CalledProcessError, RuntimeError) as e:
        print(f"error: failure to measure bandwidth. the wisp server may not have started properly.")
        print(e)
        result = "DNF"

      table[-1].append(result)
      util.kill_job(server_job, *client_jobs)

  util.kill_job(echo_process)

  #print out our results
  print("WispMark has finshed.\n\n")
  cpu_regex = r'model name.+?: (.+?)\n'
  cpu_names = re.findall(cpu_regex, p"/proc/cpuinfo".read_text())
  print(f"CPU: {cpu_names[0]} (x{len(cpu_names)})")
  print(f"Test duration: {test_duration}s")

  print_table(table, print_md)

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description=f"A benchmarking tool for Wisp protocol implementations.")
  parser.add_argument("--duration", default=test_duration, help=f"The duration of each test, in seconds. The default is {test_duration}s.")
  parser.add_argument("--print-md", default=print_md, action="store_true", help="Print a markdown table after test results are complete.")
  args = parser.parse_args()
  test_duration = int(args.duration)
  print_md = bool(args.print_md)
  
  try:
    main()
  except Exception as e:
    traceback.print_exc() 
    util.xonsh_jobs.hup_all_jobs()
