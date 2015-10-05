#!/bin/bash

echo -n 'VPN: ' ; 
{
    pgrep -f '/var/run/openvpn/redhat.pid' >/dev/null 2>&1 && echo 'RedHat'
    pgrep -f '/var/run/fastd.home.pid' >/dev/null 2>&1 && echo 'TTNN'
    nmcli -m t -f TYPE,NAME c s --active | sed -n -e '/vpn[[:space:]]*/s///p' | sed 's/[[:space:]]*$//'
} | paste -sd ',' - | sed -e 's/^,//' -e 's/,$//' | sed -e 's/^$/n\/a/'
exit 0
