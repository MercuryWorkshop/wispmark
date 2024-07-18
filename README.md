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