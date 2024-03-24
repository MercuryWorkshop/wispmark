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
wisp-server-node             | 78.26 MiB/s        | 105.03 MiB/s        | 116.31 MiB/s | 101.81 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-server-python (python3) | 86.77 MiB/s        | 132.99 MiB/s        | 437.66 MiB/s | 562.46 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
wisp-server-python (pypy3)   | 85.9 MiB/s         | 112.86 MiB/s        | 115.64 MiB/s | 108.68 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
epoxy-server                 | 83.8 MiB/s         | 255.34 MiB/s        | 478.82 MiB/s | 726.57 MiB/s 
-----------------------------+--------------------+---------------------+--------------+---------------
WispServerCpp                | DNF                | DNF                 | DNF          | DNF          
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