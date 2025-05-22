#!/usr/bin/env xonsh

import xonsh
import pathlib
import contextlib
import re
import os
import subprocess
import time

base_path = pathlib.Path(__file__).resolve().parent
if hasattr(xonsh, "jobs"):
  xonsh_jobs = xonsh.jobs
else:
  xonsh_jobs = xonsh.procs.jobs

def last_job():
  jobs = list(xonsh_jobs.get_jobs().values())
  if not jobs:
    return None
  last_job = max(jobs, key=lambda x: x["started"])
  return last_job

def kill_job(*jobs):
  for job in jobs:
    if not job:
      continue
    for pid in job["pids"]:
      try:
        kill @(pid)
      except subprocess.CalledProcessError:
        pass

def kill_by_port(target_port):
  netstat_out = $(sudo netstat -tulpn | grep LISTEN)
  process_regex = r':(\d+).+?(\d+)/'
  for port, pid in re.findall(process_regex, netstat_out):
    if int(port) == target_port:
      try:
        kill @(pid)
      except subprocess.CalledProcessError:
        pass

#calculate the bandwidth on a tcp port over a certain interval
def measure_bandwidth(port, duration):
  start = time.time()
  iftop_out = $(timeout @(duration * 2) sudo iftop -i lo -f @(f"port {port}") -t -s @(duration) -B 2>/dev/null)
  iftop_regex = r'Cumulative.+?:.+?([\d.]+)([A-Z]+)\n'
  end = time.time()

  unit_names = ["B", "KB", "MB", "GB", "TB"]
  amount, unit = re.findall(iftop_regex, iftop_out)[0]
  multiplier = 1024 ** unit_names.index(unit)
  return float(amount) * multiplier / (end - start)

@contextlib.contextmanager
def temp_cd(path):
  original_path = os.getcwd()
  os.chdir(path)
  try:
    yield
  finally:
    os.chdir(original_path)

def is_wsl():
  binfmt_path = p"/proc/sys/fs/binfmt_misc/"
  return bool(list(binfmt_path.rglob("WSL*")))

def get_cpu():
  if is_wsl():
    powershell_cmd = "Get-CimInstance -ClassName Win32_Processor | Select-Object -ExpandProperty Name"
    powershell_path = "/mnt/c/Windows/System32/WindowsPowershell/v1.0/powershell.exe" 
    cpu_name = $(@(powershell_path) -command @(powershell_cmd)).strip()

  else:
    cpu_regex = r'model name.+?: (.+?)\n'
    cpu_names = re.findall(cpu_regex, p"/proc/cpuinfo".read_text())
    if len(cpu_names) == 0:
      cpu_arch = $(uname -m).strip()
      cpu_name = f"Unknown {cpu_arch} CPU"
    else:
      cpu_name = cpu_names[0]

  count_regex = r'processor.+?: (.+?)\n'
  cpu_count = len(re.findall(count_regex, p"/proc/cpuinfo".read_text()))
  return f"{cpu_name} (x{cpu_count})"
