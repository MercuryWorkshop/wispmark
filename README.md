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
Note that test results can vary wildly across CPUs.
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
