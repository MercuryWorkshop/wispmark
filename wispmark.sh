#!/bin/bash

if [ ! -d ".venv" ]; then
  python3 -m venv .venv
  source .venv/bin/activate
fi

if ! python3 -c "import requests" 2> /dev/null; then
  pip3 install -r requirements.txt
fi

python3 ./wispmark.py "$@"
