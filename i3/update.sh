#!/bin/bash

here=$(readlink -f $(dirname $0))

if [ ! -d $here/venv ]; then
    virtualenv -p python3 --system-site-packages $here/venv
fi
dpkg -l libiw-dev >/dev/null 2>&1 || sudo apt-get install -y libiw-dev
$here/venv/bin/pip install -U -r $here/requirements.txt
patch --dry-run -p1 -R -d $here -i $here/apiclient-fix.patch >/dev/null 2>&1 || patch -p1 -d $here -i $here/apiclient-fix.patch
