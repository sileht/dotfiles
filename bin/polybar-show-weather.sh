#!/bin/bash

filter="polybar.*config.ini.*weather"
present=$(pgrep -f "$filter")
if [ ! "$present" ] ; then
    nohup polybar -c ~/.env/polybar/config.ini weather  >/dev/null 2>&1 &
    exit 0
fi
pkill -f "$filter"
