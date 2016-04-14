#!/bin/bash

echo -n 'VPN: ' ; 
{
    pgrep -F '/var/run/openvpn/redhat.pid' >/dev/null 2>&1 && echo 'RedHat'
    pgrep -F '/var/run/fastd.home.pid' >/dev/null 2>&1 && echo 'TTNN'
    [ -x "$(which nmcli 2>/dev/null)" ] && nmcli -m t -f TYPE,NAME c s --active | sed -n -e '/vpn[[:space:]]*/s///p' | sed 's/[[:space:]]*$//'
} | paste -sd ',' - | sed -e 's/^,//' -e 's/,$//' | sed -e 's/^$/n\/a/'
exit 0
