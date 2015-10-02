#!/bin/bash

here=$(readlink -f $(dirname $0))

if [ ! -d $here/venv ]; then
    virtualenv -p python3 $here/venv
fi
dpkg -l libiw-dev >/dev/null 2>&1 || sudo apt-get install -y libiw-dev


cat > i3pystatus-reqs.txt <<EOF
-e git+https://github.com/enkore/i3pystatus#egg=i3pystatus
netifaces
basiciw
colour
pywapi
keyring
psutil
pip
paramiko
EOF

cleanup(){
    rm -f i3pystatus-reqs.txt
}
trap 'cleanup' EXIT

ln -sf $here/livestatus.py $here/venv/src/i3pystatus/i3pystatus/
$here/venv/bin/pip install -U --allow-unverified pywapi --allow-external pywapi -r i3pystatus-reqs.txt

