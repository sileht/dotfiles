#!/bin/sh

while [ 1 ]; do
    if [ "$(cat /sys/class/power_supply/AC/online)" == 1 ]; then
        pacman_updates=$(checkupdates 2> /dev/null | wc -l )

        fwupdmgr refresh >> /dev/null 2>&1
        fw_updates=$(fwupdmgr get-updates 2> /dev/null | grep -c "Updatable")

        output=
        [ "$pacman_updates" -gt 0 ] && output="$output, $pacman_updates pkg(s)"
        [ "$fw_updates" -gt 0 ] && output="$output, $fw_updates fw(s)"

        [ "$output" ] && echo "ﮮ ${output:1}" || echo ""
        sleep 3600
    else
        sleep 600
    fi
done
