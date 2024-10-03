# WispMark

WispMark is a benchmarking tool for Wisp protocol implementations.

## Installation:
To run this repository, install the Xonsh shell, and all the dependencies for the Wisp implementations. 

You need:
- Git
- CPython and PyPy
- NodeJS
- Rust Nightly
- GCC
- iftop

You must also be on a recent Linux distribution. Debian 12 and Arch Linux have been tested to work.

An easy way to install Xonsh is to first clone this repo, then run the following commands:
```
pip3 install -venv .venv
source .venv/bin/activate
pip3 install -r requirements.txt
```

Then run ./wispmark.xsh to start the tests.

## Methodology:
This program pairs each Wisp server with each Wisp client, with a TCP echo server running on port 6002. The amount of traffic passing through that port is used to calculate the bandwidth that was achieved with each configuration. 

### Implementations Tested:
Server:
- [wisp-server-node](https://github.com/MercuryWorkshop/wisp-server-node)
- [wisp-js](https://github.com/MercuryWorkshop/wisp-client-js/blob/rewrite)
- [wisp-server-python](https://github.com/MercuryWorkshop/wisp-server-python)
- [epoxy-server](https://github.com/MercuryWorkshop/epoxy-tls/tree/multiplexed/server)
- [WispServerCpp](https://github.com/FoxMoss/WispServerCpp)

Client:
- [wisp-client-js](https://github.com/MercuryWorkshop/wisp-client-js/)
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

### Old Results:
From July 2024:
```
CPU: AMD EPYC 7763 64-Core Processor (x4)
Test duration: 60s
                             | wisp-client-js (1) | wisp-client-js (10) | wisp-mux (1) | wisp-mux (10)
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-server-node             | 564.61 MiB/s       | 655.85 MiB/s        | DNF          | 516.09 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-js                      | 455.18 MiB/s       | 524.83 MiB/s        | 483.85 MiB/s | 516.07 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-server-python (python3) | 137.09 MiB/s       | 143.83 MiB/s        | DNF          | 569.98 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-server-python (pypy3)   | 122.22 MiB/s       | 133.14 MiB/s        | 156.08 MiB/s | 144.29 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
epoxy-server                 | 384.46 MiB/s       | 431.21 MiB/s        | 359.93 MiB/s | 434.56 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
WispServerCpp                | DNF                | 448.17 MiB/s        | DNF          | 526.3 MiB/s  

CPU: 13th Gen Intel(R) Core(TM) i7-1360P (x16)
Test duration: 10s
                             | wisp-client-js (1) | wisp-client-js (10) | wisp-mux (1)  | wisp-mux (10)
-----------------------------+--------------------+---------------------+---------------+---------------
wisp-server-node             | 848.73 MiB/s       | 1419.97 MiB/s       | 1277.58 MiB/s | 1264.52 MiB/s
-----------------------------+--------------------+---------------------+---------------+---------------
wisp-js                      | 812.4 MiB/s        | 1181.24 MiB/s       | 1192.8 MiB/s  | 1215.22 MiB/s
-----------------------------+--------------------+---------------------+---------------+---------------
wisp-server-python (python3) | 206.11 MiB/s       | 213.21 MiB/s        | 900.24 MiB/s  | 991.37 MiB/s 
-----------------------------+--------------------+---------------------+---------------+---------------
wisp-server-python (pypy3)   | 238.14 MiB/s       | 240.52 MiB/s        | 379.67 MiB/s  | DNF          
-----------------------------+--------------------+---------------------+---------------+---------------
epoxy-server                 | 803.06 MiB/s       | 1392.41 MiB/s       | 1302.48 MiB/s | 1716.66 MiB/s
-----------------------------+--------------------+---------------------+---------------+---------------
WispServerCpp                | 405.76 MiB/s       | 673.73 MiB/s        | 591.34 MiB/s  | 578.8 MiB/s  

CPU: 13th Gen Intel(R) Core(TM) i7-1360P (x16)
Test duration: 60s
                             | wisp-client-js (1) | wisp-client-js (10) | wisp-mux (1)  | wisp-mux (10)
-----------------------------+--------------------+---------------------+---------------+---------------
wisp-server-node             | 893.27 MiB/s       | 1253.8 MiB/s        | 1382.92 MiB/s | 1402.81 MiB/s
-----------------------------+--------------------+---------------------+---------------+---------------
wisp-js                      | 900.04 MiB/s       | 1312.59 MiB/s       | 1296.05 MiB/s | 1282.25 MiB/s
-----------------------------+--------------------+---------------------+---------------+---------------
wisp-server-python (python3) | 212.61 MiB/s       | 186.74 MiB/s        | 941.82 MiB/s  | 1005.01 MiB/s
-----------------------------+--------------------+---------------------+---------------+---------------
wisp-server-python (pypy3)   | 217.36 MiB/s       | 221.13 MiB/s        | 397.41 MiB/s  | 419.53 MiB/s 
-----------------------------+--------------------+---------------------+---------------+---------------
epoxy-server                 | 866.1 MiB/s        | 1154.24 MiB/s       | 1297.09 MiB/s | 1485.32 MiB/s
-----------------------------+--------------------+---------------------+---------------+---------------
WispServerCpp                | 385.36 MiB/s       | 728.39 MiB/s        | 540.07 MiB/s  | 567.05 MiB/s 
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
