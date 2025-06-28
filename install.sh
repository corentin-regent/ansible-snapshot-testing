#!/bin/bash

set -e

VENV=.venv
if [ ! -d "$VENV" ]; then
    python3 -m venv "$VENV"
fi

. .venv/bin/activate

python3 -m pip install -r requirements.txt
