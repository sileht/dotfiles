#!/bin/bash


MYPID=$$
PIDS_FILE=~/.tmp/mutt-remote
TMPDIR=~/.tmp/

tmpfile=$(mktemp)

function attachements_check(){
    if [ -e "$PIDS_FILE" ]; then
        nb_process=$(($(cat $PIDS_FILE) + 1)) 
        echo $nb_process > $PIDS_FILE
        return
    else
        echo 1 > $PIDS_FILE
        echo "Start attachements watcher process"
        ssh -TqYax gizmo 'inotifywait -m -q -e close_write --format %f /home/sileht/.mutt/attachments' | while read file ; do 
            sleep 1
            scp gizmo:/home/sileht/.mutt/attachments/$file $TMPDIR/$file
            #wget --no-check-certificate -q -O $TMPDIR/$file https://dl.sileht.net/mail/$file
            gnome-open $TMPDIR/$file
        done
    fi
}

function finish(){
    nb_process=$(($(cat $PIDS_FILE) - 1)) 
    echo $nb_process > $PIDS_FILE
    if [ $nb_process -eq 0 ]; then
        rm -f $PIDS_FILE
        echo "Stop attachements watcher process"
        ssh -qTYax gizmo "killall inotifywait"
    fi
}

trap "finish" EXIT QUIT

attachements_check &
ssh -taxq gizmo "mutt $@"

