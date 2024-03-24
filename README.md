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
This program pairs each Wisp server with each Wisp client, with a TCP echo server running on port 6002. The amount of traffic passing through that port is used to calculate the bandwith that was achieved with each configuration.

## Current Results:
```
CPU: AMD EPYC 7763 64-Core Processor (x4)
                             | wisp-client-js               | wisp-mux                    
-----------------------------+------------------------------+-----------------------------
wisp-server-node             | 101.43 MiB/s                 | 102.43 MiB/s                
-----------------------------+------------------------------+-----------------------------
wisp-server-python (python3) | 107.36 MiB/s                 | 559.15 MiB/s                
-----------------------------+------------------------------+-----------------------------
wisp-server-python (pypy3)   | 102.83 MiB/s                 | 109.49 MiB/s                
-----------------------------+------------------------------+-----------------------------
epoxy-server                 | 298.33 MiB/s                 | 646.33 MiB/s                
-----------------------------+------------------------------+-----------------------------
WispServerCpp                | DNF                          | DNF                         
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