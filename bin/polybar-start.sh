#!/bin/bash

pkill -x polybar
pkill -x ntfd
pkill -x picom

~/.zinit/plugins/kamek-pf---ntfd/ntfd &

TRAY_POSITION=center polybar -c ~/.env/polybar/config.ini top &
polybar -c ~/.env/polybar/config.ini bottom &
polybar -c ~/.env/polybar/config.ini top-aux &
polybar -c ~/.env/polybar/config.ini bottom-aux &
picom --config ~/.env/picom.conf &
wait
