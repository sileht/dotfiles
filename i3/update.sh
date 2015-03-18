#!/bin/bash

here=$(readlink -f $(dirname $0))

if [ ! -d $here/venv ]; then
    virtualenv -p python3 $here/venv
fi
sudo apt-get install -y libiw-dev
$here/venv/bin/pip install -U -r i3pystatus-reqs.txt
