# WispMark

WispMark is a benchmarking tool for Wisp protocol implementations.

## Installation:
To run this repository, install the Xonsh shell, and all the dependencies for the Wisp implementations. 

You need:
- Git
- CPython and PyPy
- NodeJS
- Rust Nightly
- Crystal
- GCC
- iftop

You must also be on a recent Linux distribution. Debian 12 and Arch Linux have been tested to work.

An easy way to install Xonsh is to first clone this repo, then run the following commands:
```
python3 -m venv .venv
source .venv/bin/activate
pip3 install -r requirements.txt
```

Then run ./wispmark.xsh to start the tests.

Note: if you want to rebuild all of the server and client implementations to run a clean test, you can run: `git clean -ffXd`

## Methodology:
This program pairs each Wisp server with each Wisp client, with a TCP echo server running on port 6002. The amount of traffic passing through that port is used to calculate the bandwidth that was achieved with each configuration. 

### Implementations Tested:
Server:
- [wisp-server-node](https://github.com/MercuryWorkshop/wisp-server-node)
- [wisp-js](https://github.com/MercuryWorkshop/wisp-client-js/blob/rewrite/src/server)
- [wisp-server-python](https://github.com/MercuryWorkshop/wisp-server-python)
- [epoxy-server](https://github.com/MercuryWorkshop/epoxy-tls/tree/multiplexed/server)
- [WispServerCpp](https://github.com/FoxMoss/WispServerCpp)

Client:
- [wisp-js](https://github.com/MercuryWorkshop/wisp-client-js/blob/rewrite/src/client)
- [wisp-mux](https://github.com/MercuryWorkshop/epoxy-tls/tree/multiplexed/simple-wisp-client)

## Usage:
```
usage: wispmark.xsh [-h] [--duration DURATION]

A benchmarking tool for Wisp protocol implementations.

options:
  -h, --help           show this help message and exit
  --duration DURATION  The duration of each test, in seconds. The default is 10s.
```

## Current Results:
Note that test results can vary wildly across different CPUs.

```
CPU: AMD EPYC 7763 64-Core Processor (x4)
Test duration: 30s
                              | wisp-js (1)  | wisp-js (10) | wisp-js (5x10) | wisp-mux (1) | wisp-mux (10) | wisp-mux (5x10)
------------------------------+--------------+--------------+----------------+--------------+---------------+-----------------
wisp-server-node              | 528.34 MiB/s | 497.42 MiB/s | 436.79 MiB/s   | 460.2 MiB/s  | 432.86 MiB/s  | 393.69 MiB/s
------------------------------+--------------+--------------+----------------+--------------+---------------+-----------------
wisp-js                       | 504.12 MiB/s | 510.49 MiB/s | 493.95 MiB/s   | 494.15 MiB/s | 463.65 MiB/s  | 430.02 MiB/s
------------------------------+--------------+--------------+----------------+--------------+---------------+-----------------
wisp-server-python (python3)  | 592.0 MiB/s  | 683.76 MiB/s | 666.32 MiB/s   | 494.15 MiB/s | 456.96 MiB/s  | 622.57 MiB/s
------------------------------+--------------+--------------+----------------+--------------+---------------+-----------------
epoxy-server (singlethread)   | 581.76 MiB/s | 815.15 MiB/s | 761.64 MiB/s   | 580.03 MiB/s | 967.78 MiB/s  | 743.99 MiB/s
------------------------------+--------------+--------------+----------------+--------------+---------------+-----------------
epoxy-server (multithread)    | 565.49 MiB/s | 810.79 MiB/s | 867.38 MiB/s   | 556.75 MiB/s | 994.0 MiB/s   | 1012.37 MiB/s
------------------------------+--------------+--------------+----------------+--------------+---------------+-----------------
epoxy-server (multithreadalt) | 555.11 MiB/s | 768.52 MiB/s | 803.33 MiB/s   | 561.86 MiB/s | 983.38 MiB/s  | 1056.13 MiB/s
------------------------------+--------------+--------------+----------------+--------------+---------------+-----------------
WispServerCpp                 | DNF          | 443.09 MiB/s | 532.42 MiB/s   | 127.28 MiB/s | 160.08 MiB/s  | 261.04 MiB/s
```

### Old Results:

From September 2024:
```
CPU: AMD EPYC 7763 64-Core Processor (x4)
Test duration: 30s
                             | wisp-client-js (1) | wisp-client-js (10) | wisp-mux (1) | wisp-mux (10)
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-server-node             | 514.8 MiB/s        | 538.3 MiB/s         | 544.88 MiB/s | 453.33 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-js                      | 468.02 MiB/s       | 550.85 MiB/s        | 473.53 MiB/s | 494.37 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-server-python (python3) | 518.12 MiB/s       | 720.57 MiB/s        | 487.35 MiB/s | 619.57 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-server-python (pypy3)   | 147.56 MiB/s       | 135.31 MiB/s        | 138.85 MiB/s | 166.3 MiB/s  
-----------------------------+--------------------+---------------------+--------------+---------------
epoxy-server                 | 545.03 MiB/s       | 782.16 MiB/s        | 578.43 MiB/s | DNF          
-----------------------------+--------------------+---------------------+--------------+---------------
WispServerCpp                | DNF                | 504.35 MiB/s        | 124.9 MiB/s  | 146.64 MiB/s 

CPU: 13th Gen Intel(R) Core(TM) i7-1360P (x16)
Test duration: 10s
                              | wisp-client-js (1) | wisp-client-js (10) | wisp-mux (1)  | wisp-mux (10)
------------------------------+--------------------+---------------------+---------------+---------------
wisp-server-node              | 861.31 MiB/s       | 1312.71 MiB/s       | 1331.31 MiB/s | 1322.27 MiB/s
------------------------------+--------------------+---------------------+---------------+---------------
wisp-js                       | 852.83 MiB/s       | 1293.41 MiB/s       | 1480.35 MiB/s | 1320.88 MiB/s
------------------------------+--------------------+---------------------+---------------+---------------
wisp-server-python (python3)  | 856.08 MiB/s       | 1221.94 MiB/s       | 1334.07 MiB/s | 1203.15 MiB/s
------------------------------+--------------------+---------------------+---------------+---------------
epoxy-server (singlethread)   | 855.38 MiB/s       | 1584.74 MiB/s       | 2023.85 MiB/s | 1829.74 MiB/s
------------------------------+--------------------+---------------------+---------------+---------------
epoxy-server (multithread)    | 833.42 MiB/s       | 1379.21 MiB/s       | 1822.59 MiB/s | 1778.17 MiB/s
------------------------------+--------------------+---------------------+---------------+---------------
epoxy-server (multithreadalt) | 808.71 MiB/s       | 1406.15 MiB/s       | 1723.93 MiB/s | 1812.51 MiB/s
------------------------------+--------------------+---------------------+---------------+---------------
WispServerCpp                 | 482.9 MiB/s        | 797.9 MiB/s         | 613.95 MiB/s  | 603.26 MiB/s

CPU: 13th Gen Intel(R) Core(TM) i7-1360P (x16)
Test duration: 30s
                              | wisp-client-js (1) | wisp-client-js (10) | wisp-mux (1)  | wisp-mux (10)
------------------------------+--------------------+---------------------+---------------+---------------
wisp-server-node              | 876.46 MiB/s       | 1380.63 MiB/s       | 1424.88 MiB/s | 1449.47 MiB/s
------------------------------+--------------------+---------------------+---------------+---------------
wisp-js                       | 892.37 MiB/s       | 1383.74 MiB/s       | 1492.41 MiB/s | 1001.98 MiB/s
------------------------------+--------------------+---------------------+---------------+---------------
wisp-server-python (python3)  | 890.42 MiB/s       | 1222.85 MiB/s       | 1276.44 MiB/s | 1269.45 MiB/s
------------------------------+--------------------+---------------------+---------------+---------------
epoxy-server (singlethread)   | 910.83 MiB/s       | 853.43 MiB/s        | 2181.43 MiB/s | 1899.21 MiB/s
------------------------------+--------------------+---------------------+---------------+---------------
epoxy-server (multithread)    | 888.89 MiB/s       | 1519.25 MiB/s       | 1709.19 MiB/s | 1428.15 MiB/s
------------------------------+--------------------+---------------------+---------------+---------------
epoxy-server (multithreadalt) | 884.12 MiB/s       | 1501.64 MiB/s       | 1773.11 MiB/s | 1922.66 MiB/s
------------------------------+--------------------+---------------------+---------------+---------------
WispServerCpp                 | 514.36 MiB/s       | 907.06 MiB/s        | 683.91 MiB/s  | 694.13 MiB/s 
```

## Copyright:
This program is licensed under the GNU GPL v3.

```
WispMark: A benchmarking tool for Wisp protocol implementations.
Copyright (C) 2024 ading2210

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```
