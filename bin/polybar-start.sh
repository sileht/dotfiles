#!/bin/bash

pkill -x polybar

TRAY_POSITION=center polybar -c ~/.env/polybar/config.ini top &

DISPLAY_AUX=$(xrandr | grep ' connected' | grep -v primary | awk '{print $1}')
if [ "$DISPLAY_AUX" ]; then
    DISPLAY_AUX=${DISPLAY_AUX} polybar -c ~/.env/polybar/config.ini aux &
fi

wait
