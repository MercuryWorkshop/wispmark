#!/usr/bin/env xonsh

import os
import sys

import server
import client
import util

if os.geteuid() != 0:
  print("please run this script as root")
  sys.exit(1)

print(util.measure_bandwidth(8080, 5))