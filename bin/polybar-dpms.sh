#!/bin/bash

format=""
format_disabled=""
#format_disabled="冷 off"


enabled=$(xset q | grep -c "DPMS is Enabled")

case $1-$enabled in
    toggle-0) xset +dpms ;;
    toggle-1) xset -dpms ;;
    output-0)echo $format_disabled ;;
    output-1)echo $format ;;
esac
