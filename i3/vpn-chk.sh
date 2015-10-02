#!/bin/bash

echo -n 'VPN: ' ; 
{
    [ -e '/var/run/openvpn/redhat.pid'   ] && echo 'RedHat'
    [ -e '/var/run/fastd.home.pid'   ] && echo 'TTNN'
    nmcli -m t -f TYPE,NAME c s --active | sed -n -e '/vpn[[:space:]]*/s///p' | sed 's/[[:space:]]*$//'
} | paste -sd ',' - | sed -e 's/^,//' -e 's/,$//' | sed -e 's/^$/n\/a/'
exit 0
