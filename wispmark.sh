#!/bin/bash

if [ ! -d ".venv" ]; then
  python3 -m venv .venv
  source .venv/bin/activate
fi

if ! python3 -c "import xonsh, requests" 2> /dev/null; then
  pip3 install -r requirements.txt
fi

xonsh ./wispmark.xsh "$@"