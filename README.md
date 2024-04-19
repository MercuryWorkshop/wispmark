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
wisp-server-node             | 536.0 MiB/s        | 628.35 MiB/s        | 498.19 MiB/s | 474.22 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-server-python (python3) | 117.87 MiB/s       | 128.86 MiB/s        | 392.13 MiB/s | 533.12 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-server-python (pypy3)   | 104.3 MiB/s        | 111.73 MiB/s        | 115.59 MiB/s | 112.65 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
epoxy-server                 | 363.32 MiB/s       | 422.56 MiB/s        | 335.45 MiB/s | 391.56 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
WispServerCpp                | 276.22 MiB/s       | 469.96 MiB/s        | 232.41 MiB/s | 383.23 MiB/s 
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