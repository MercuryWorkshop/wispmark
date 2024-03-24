#!/usr/bin/env xonsh

import os
import sys
import subprocess
import traceback
import time
import requests
import xonsh

import server
import client
import util

$RAISE_SUBPROC_ERROR = True
wisp_port = 6001
echo_port = 6002

def run_echo():
  socat TCP4-LISTEN:@(echo_port),fork EXEC:cat &
  return util.last_job()

def wait_for_server():
  for i in range(0, 10):
    try:
      requests.head(f"http://127.0.0.1:{wisp_port}/", timeout=1)
      break
    except:
      time.sleep(0.5)
  else:
    raise RuntimeError("Server failed to start in time.")

def main():
  sudo true
  echo_process = run_echo()

  for implementation in server.implementations + client.implementations:
    if implementation.is_installed():
      continue
    implementation.install()

  for server_impl in server.implementations:
    for client_impl in client.implementations:
      print(f"testing {server_impl.name} with {client_impl.name}")
      
      print("starting server")
      server_job = server_impl.run(wisp_port)
      wait_for_server()

      print("running client and recording speeds...")
      client_job = client_impl.run(wisp_port, echo_port)
      speed = util.measure_bandwidth(echo_port, 5)

      print(f"result: {round(speed / (1024 ** 2), 2)} MiB/s")
      util.kill_job(server_job, client_job)


  util.kill_job(echo_process)

if __name__ == "__main__":
  try:
    main()
  except Exception as e:
    traceback.print_exc() 
    xonsh.jobs.hup_all_jobs()