#!/bin/bash
URL="https://api.surfshark.com/v3/server/clusters"
TPL="template"
SERVERS="$TPL/servers.json"

echo
echo "WARNING: Certs must be updated manually!"
echo

mkdir -p $TPL
if ! curl -L $URL >$SERVERS; then
    exit
fi
