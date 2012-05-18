#!/bin/bash

REMOTEPATH=/home/sileht/.mutt/attachments/
HTTPPATH='http://dl.sileht.net/mail/'

FILENAME=redirect.html


cat > $REMOTEPATH$FILENAME <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
<meta http-equiv="refresh" content="0; url=$1" />
<title>Redirection</title>
<meta name="robots" content="noindex,follow" />
</head>

<body>
<p><a href="$1">Redirection</a></p>
</body>
</html>
EOF


chmod 644 "$REMOTEPATH$FILENAME"

clear
echo -e "\nOpen $HTTPPATH$FILENAME to be redirect to the correct site.\n"
echo -n "(D)elete* or (K)eep : "
read -n 1 anwser
case $anwser in
    K)
        ;;
    *)

        clear
        echo "Removing file..."
        rm -f "$REMOTEPATH$FILENAME"
        ;;
esac
clear
