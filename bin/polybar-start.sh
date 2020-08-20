#!/bin/bash

pkill -x polybar

TRAY_POSITION=center polybar -c ~/.env/polybar/config.ini top &
polybar -c ~/.env/polybar/config.ini aux &
#polybar -c ~/.env/polybar/config.ini weather &
wait
