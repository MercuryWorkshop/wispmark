import sys
import os
import time
import threading

if len(sys.argv) < 3:
  print("usage: python3 netwatch.py <port> <duration>")
  print("please pipe the output of 'tcpdump -i lo -e -q -nn -t' into this")
  sys.exit(1)

target_port = int(sys.argv[1])
time_limit = float(sys.argv[2])

time_start = time.time()
last_measurement = time.time()
total_bytes = 0

def record_thread():
  global total_bytes
  while True:
    line = sys.stdin.readline()[52:].strip()
    len_str, addr_str, _ = line.split(":")
    source_addr, destination_addr = addr_str.split(" > ")
    source_port = int(source_addr.split(".")[-1])
    destination_port = int(destination_addr.split(".")[-1])
    length = int(len_str)

    if destination_port != 8080 and source_port != 8080:
      continue

    total_bytes += length

t = threading.Thread(target=record_thread, daemon=True)
t.start()

while True:
  time.sleep(1)
  now = time.time()
  speed = total_bytes / (now - last_measurement)
  print(speed / 1024)

  last_measurement = time.time()
  total_bytes = 0

  if now - time_start > time_limit:
    break
