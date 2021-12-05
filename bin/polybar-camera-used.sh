#!/bin/bash

used="$(fuser /dev/video* 2>&1)"
if [ -n "$used" ]; then
    color="%{F#FF0000}"
    text="📷"
    echo "${color}${text}"
fi
