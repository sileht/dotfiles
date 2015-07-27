#!/bin/bash

FILENAME=$1
MIMETYPE=$2
REMOTE_DIR="/tmp"
BASENAME=$(basename "${FILENAME}")
REMOTE_FILE="${REMOTE_DIR}/${BASENAME}"

scp -P 62222 $FILENAME sileht@localhost:$REMOTE_FILE

COMMAND="chmod 600 '${REMOTE_FILE}' ; DISPLAY=:0 run-mailcap --action=view '"
[ -n "${MIMETYPE}" -a "${MIMETYPE}" != "application/octet-stream" ] && COMMAND="${COMMAND}${MIMETYPE}:"
COMMAND="${COMMAND}${REMOTE_FILE}' > /dev/null & sleep 2"

ssh -p 62222 sileht@localhost "${COMMAND}"

clear
exit 0
