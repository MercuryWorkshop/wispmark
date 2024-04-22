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
wisp-server-node             | 562.97 MiB/s       | 508.47 MiB/s        | 449.32 MiB/s | 450.9 MiB/s  
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-js                      | 415.07 MiB/s       | 459.76 MiB/s        | 456.14 MiB/s | 367.27 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-server-python (python3) | 121.27 MiB/s       | 132.82 MiB/s        | 406.74 MiB/s | 540.22 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-server-python (pypy3)   | 103.49 MiB/s       | 116.27 MiB/s        | 118.3 MiB/s  | 106.51 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
epoxy-server                 | 396.7 MiB/s        | 457.08 MiB/s        | 348.25 MiB/s | 457.48 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
WispServerCpp                | DNF                | 459.61 MiB/s        | 227.08 MiB/s | 486.46 MiB/s 
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