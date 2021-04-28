#!/bin/bash
URL="???"
TPL="template"
SERVERS="$TPL/servers.json"

echo "Static servers bundle"
exit

echo
echo "WARNING: Certs must be updated manually!"
echo

mkdir -p $TPL
if ! curl -L $URL >$SERVERS; then
    exit
fi
