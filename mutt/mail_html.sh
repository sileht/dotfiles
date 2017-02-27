#!/bin/bash

echo
#charset=$1
#file=$2
#shift
#elinks -dump 1 -dump-color-mode 3 -dump-charset $charset "$file"
#if [ $? -ne 0 ]; then
    links -dump -html-numbered-links 1 -html-images 1 -html-assume-codepage $charset "$@"
    if [ $? -ne 0 ]; then
        links -dump -html-numbered-links 1 -html-images 1  "$@"
        if [ $? -ne 0 ]; then
            cat "$@"
        fi
    fi
#fi
