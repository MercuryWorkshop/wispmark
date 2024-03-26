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

## Current Results:
```
CPU: AMD EPYC 7763 64-Core Processor (x4)
                             | wisp-client-js (1) | wisp-client-js (10) | wisp-mux (1) | wisp-mux (10)
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-server-node             | 498.18 MiB/s       | 564.97 MiB/s        | 495.16 MiB/s | 505.18 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-server-python (python3) | 116.69 MiB/s       | 109.15 MiB/s        | 371.67 MiB/s | 568.18 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-server-python (pypy3)   | 99.54 MiB/s        | 113.21 MiB/s        | 121.69 MiB/s | 107.46 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
epoxy-server                 | 408.27 MiB/s       | 541.69 MiB/s        | 468.02 MiB/s | 661.22 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
WispServerCpp                | 615.92 MiB/s       | 1017.92 MiB/s       | 718.35 MiB/s | 1135.12 MiB/s
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