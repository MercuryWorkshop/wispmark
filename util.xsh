#!/usr/bin/env xonsh

import xonsh

def get_last_job():
  jobs = list(xonsh.jobs.get_jobs().values())
  if not jobs:
    return None
  last_job = max(jobs, key=lambda x: x["started"])
  return last_job

#calculate the bandwidth on a tcp port over a certain interval
def measure_bandwidth(port, duration):
  netwatch_out = $(tcpdump -i lo -e -q -nn -t 2> /dev/null | python3 netwatch.py @(port) @(duration))
  netwatch_data = [float(line) for line in netwatch_out.strip().split("\n")]
  return sum(netwatch_data) / len(netwatch_data)