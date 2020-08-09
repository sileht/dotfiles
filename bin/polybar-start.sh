#!/bin/bash

pkill -x polybar
pkill -x ntfd

/home/sileht/.zinit/plugins/kamek-pf---ntfd/ntfd &

TRAY_POSITION=center polybar -c /home/sileht/.env/polybar/config.ini top &
polybar -c /home/sileht/.env/polybar/config.ini bottom &
polybar -c /home/sileht/.env/polybar/config.ini top-aux &
polybar -c /home/sileht/.env/polybar/config.ini bottom-aux &
wait
