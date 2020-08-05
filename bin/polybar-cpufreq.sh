#!/bin/bash


display() {
    local freq=$(echo $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq) / 1024 / 1024  | bc -l)
    printf "%s %.02fGhz\n" $1 $freq
}

run () {
    sudo cpupower frequency-set -g $1
}

mode=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
case $1-$mode in
    toggle-performance) run powersave ;;
    toggle-powersave) run performance ;;
    output-performance) display "" ;;
    output-power) display "鈴" ;;
esac
