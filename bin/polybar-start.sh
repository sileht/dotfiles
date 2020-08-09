#!/bin/bash

pkill -x polybar

TRAY_POSITION=center polybar -c ~/.env/polybar/config.ini top &
polybar -c ~/.env/polybar/config.ini bottom &
polybar -c ~/.env/polybar/config.ini top-aux &
polybar -c ~/.env/polybar/config.ini bottom-aux &
wait
