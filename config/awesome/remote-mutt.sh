#!/bin/bash

TMPDIR=~/.tmp/
function attachements_check(){
    ssh -TqYax site 'inotifywait -m -q -e close_write --format %f /home/sileht/.mutt/attachments' | while read file ; do 
        sleep 1
        wget --no-check-certificate -q -O $TMPDIR/$file https://dl.sileht.net/mail/$file
        gnome-open $TMPDIR/$file
    done
}

attachements_check &
pid=$!

function finish(){
    pkill -P $pid
    kill $pid
    ssh -qTYax site "killall inotifywait"
}

trap "finish" EXIT QUIT

ssh -taxq site "mutt $@"

