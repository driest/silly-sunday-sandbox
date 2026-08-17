#!/bin/bash

BIN=mitmproxy
if [ "$1" = "--dump" ] || [ "$1" = "-d" ]; then
    BIN=mitmdump
    shift
fi

if [ -x "./$BIN" ]; then
    BIN="./$BIN"
elif [ -x ".venv/bin/$BIN" ]; then
    BIN=".venv/bin/$BIN"
fi

exec "$BIN" --set confdir=./mitmcfg -s "$PWD/addon.py" "$@"
