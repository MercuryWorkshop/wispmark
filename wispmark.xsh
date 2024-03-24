#!/usr/bin/env xonsh

import os
import sys
import subprocess
import traceback
import time
import re
import requests
import xonsh

import server
import client
import util

$RAISE_SUBPROC_ERROR = True
$XONSH_SHOW_TRACEBACK = True

wisp_port = 6001
echo_port = 6002
server_timeout = 5
test_duration = 5

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
      requests.get(f"http://127.0.0.1:{wisp_port}/", timeout=0.5)
      break
    except:
      time.sleep(0.5)
  else:
    raise RuntimeError("Server failed to start in time.")

def main():
  sudo true
  install_echo()
  echo_process = run_echo()

  for implementation in server.implementations + client.implementations:
    if implementation.is_installed():
      continue
    print(f"installing {implementation.name}")
    implementation.install()

  table = [[""] + [impl.name for impl in client.implementations]]
  for server_impl in server.implementations:
    table.append([server_impl.name])
    for client_impl in client.implementations:
      print(f"testing {server_impl.name} with {client_impl.name}")
      
      print("starting server")
      server_job = server_impl.run(wisp_port)
      wait_for_server()

      print("running client and recording speeds...")
      client_job = client_impl.run(wisp_port, echo_port)

      try:
        speed = util.measure_bandwidth(echo_port, test_duration)
        result = f"{round(speed / (1024 ** 2), 2)} MiB/s"
        print(f"result: {result}")
      except subprocess.CalledProcessError as e:
        print(f"error: failure to measure bandwidth. the wisp server may not have started properly.")
        result = "DNF"

      table[-1].append(result)
      util.kill_job(server_job, client_job)

  util.kill_job(echo_process)

  #print out our results
  print("WispMark has finshed.\n\n")
  cpu_regex = r'model name.+?: (.+?)\n'
  cpu_names = re.findall(cpu_regex, p"/proc/cpuinfo".read_text())
  print(f"CPU: {cpu_names[0]} (x{len(cpu_names)})")

  col_width = 0
  for row in table:
    widths = [len(cell) for cell in row]
    col_width = max(col_width, max(widths))

  rows = []
  for row in table:
    cells = [cell.ljust(col_width) for cell in row]
    rows.append(" | ".join(cells))
  seperator = "-+-".join(["-" * col_width] * len(table[0]))
  table_str = f"\n{seperator}\n".join(rows)
  print(table_str)

if __name__ == "__main__":
  try:
    main()
  except Exception as e:
    traceback.print_exc() 
    xonsh.jobs.hup_all_jobs()