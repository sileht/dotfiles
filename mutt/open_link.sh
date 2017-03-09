#!/bin/bash

if [ "$SSH_CLIENT" ]; then
    ssh -p 62222 sileht@localhost "DISPLAY=:0 xdg-open '$1'"
else
    xdg-open "$1"
fi
