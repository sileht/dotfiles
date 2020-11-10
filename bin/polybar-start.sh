#!/bin/bash

pkill -x polybar

DISPLAYS=$(xrandr | awk '/ connected/{print $1}')
DISPLAY_PRIMARY=$(xrandr | awk '/ connected primary/{print $1}')
[ ! "$DISPLAY_PRIMARY" ]  && DISPLAY_PRIMARY=$(xrandr | awk '/ connected/{print $1;exit;}')

echo TRAY_POSITION=center polybar -c ~/.env/polybar/config.ini top &
for display in $DISPLAYS; do
    [ "$display" == "$DISPLAY_PRIMARY" ] && continue
    echo DISPLAY_AUX=${display} polybar -c ~/.env/polybar/config.ini aux &
done

wait
