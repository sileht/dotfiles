#!/bin/bash

filter="polybar.*config.ini.*weather"

TIMEOUT=10

present=$(pgrep -f "$filter")
cmd=${1:-toggle}

case $cmd in
    toggle)
        if [ "$present" ]; then
            $0 kill
        else
            $0 show
        fi
        ;;
    show)
        nohup polybar -c ~/.env/polybar/config.ini weather  > /dev/null 2>&1 &
        nohup bash -c "sleep $TIMEOUT; $0 kill"  > /dev/null 2>&1 &
        ;;
    kill)
        pkill -f "$filter"
        ;;
esac
