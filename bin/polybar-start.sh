#!/bin/bash

pkill -x polybar

TRAY_POSITION=center polybar -c ~/.env/polybar/config.ini top &

DISPLAY_NB=$(xrandr | grep ' connected' | wc -l)

if [ "$DISPLAY_NB" -ge 2 ]; then
    DISPLAY_AUX=$(xrandr | grep ' connected' | grep -v primary | awk '{print $1}')
    [ ! "$DISPLAY_AUX" ] && DISPLAY_AUX=$(xrandr | grep ' connected' | tail -1 | awk '{print $1}')
    DISPLAY_AUX=${DISPLAY_AUX} polybar -c ~/.env/polybar/config.ini aux &
fi

wait
