#!/bin/bash

output () {
    local service=$1
    local text=$2
    if systemctl is-active -q $service; then
        color="%{F#f9f9f9}"
    else
        color="%{F#5a5956}"
    fi
    echo "${color}${text}"
}

toggle() {
    local service=$1
    if systemctl is-active -q $service; then
        sudo systemctl stop $service
    else
        sudo systemctl start $service
    fi
}

CMD=$1
shift
$CMD "$@"
