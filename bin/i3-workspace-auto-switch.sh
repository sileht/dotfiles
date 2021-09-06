#!/bin/bash

pkill -O1 -f bash.*i3-workspace-auto-switch.sh

while [ 1 ]; do
    i3-msg -t subscribe -m '[ "workspace" ]' | jq --unbuffered -Mrc '. | select(.change == "urgent" and .current.urgent == true).current.name'|xargs -i -n1 i3-msg 'workspace {}'
    sleep 0.5
done
