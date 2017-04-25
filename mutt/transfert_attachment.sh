#!/bin/bash

# Expect ssh session with reverse forwarding like -R62222:localhost:2222
# and ssh-agent and ssh keys setuped

FILENAME="$1"
REMOTE_DIR="/tmp"
BASENAME=$(basename "${FILENAME}")
REMOTE_FILE="${REMOTE_DIR}/${BASENAME}"

cat "$FILENAME" | ssh -p 62222 sileht@localhost "cat > '$REMOTE_FILE' ; chmod 600 '${REMOTE_FILE}' ; DISPLAY=:0 run-mailcap --action=view '$REMOTE_FILE'"
if [ $? -ne 0 ]; then
    echo "Error during $(basename $0) execution."
    read
fi
clear
exit 0
