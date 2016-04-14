#!/bin/bash

here=$(readlink -f $(dirname $0))

if [ ! -d $here/venv ]; then
    virtualenv -p python3 --system-site-packages $here/venv
fi
dpkg -l libiw-dev >/dev/null 2>&1 || sudo apt-get install -y libiw-dev


cat > $here/i3pystatus-reqs.txt <<EOF
git+https://github.com/enkore/i3pystatus@master#egg=i3pystatus
apiclient
google-api-python-client
httplib2
oauth2client
pytz
python-dateutil
pyanybar
netifaces
basiciw
colour
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

$here/venv/bin/pip install -U -r $here/i3pystatus-reqs.txt
patch --dry-run -p1 -R -d $here -i $here/apiclient-fix.patch >/dev/null 2>&1 || patch -p1 -d $here -i $here/apiclient-fix.patch
