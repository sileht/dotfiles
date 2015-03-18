#!/bin/sh

i3status -c ~/.i3/status.conf | while :
do
    read line
    echo "$line" || exit 1
done
