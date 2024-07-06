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

## Current Results:
```
CPU: AMD EPYC 7763 64-Core Processor (x4)
                             | wisp-client-js (1) | wisp-client-js (10) | wisp-mux (1) | wisp-mux (10)
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-server-node             | 564.51 MiB/s       | 625.76 MiB/s        | 536.33 MiB/s | 518.92 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-js                      | 474.45 MiB/s       | 501.36 MiB/s        | 447.08 MiB/s | 433.11 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-server-python (python3) | 134.8 MiB/s        | 139.96 MiB/s        | 345.19 MiB/s | 490.08 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-server-python (pypy3)   | 112.51 MiB/s       | 126.27 MiB/s        | 147.62 MiB/s | 133.97 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
epoxy-server                 | 358.35 MiB/s       | 431.18 MiB/s        | 349.99 MiB/s | 412.63 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
WispServerCpp                | 269.02 MiB/s       | 552.78 MiB/s        | DNF          | 471.43 MiB/s 
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