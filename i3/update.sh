#!/bin/bash

here=$(readlink -f $(dirname $0))

if [ ! -d $here/venv ]; then
    virtualenv -p python3 --system-site-packages $here/venv
fi
dpkg -l libiw-dev >/dev/null 2>&1 || sudo apt-get install -y libiw-dev


cat > $here/i3pystatus-reqs.txt <<EOF
-e git+https://github.com/enkore/i3pystatus@master#egg=i3pystatus
pyanybar
netifaces
basiciw
colour
pywapi
keyring
psutil
pip
paramiko
keyrings.alt
EOF

cleanup(){
    rm -f $here/i3pystatus-reqs.txt
}
trap 'cleanup' EXIT

$here/venv/bin/pip install -U --allow-unverified pywapi --allow-external pywapi -r $here/i3pystatus-reqs.txt
