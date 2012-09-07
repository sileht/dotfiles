#!/bin/bash

charset=$1
shift

links -dump -html-numbered-links 1 -html-images 1 -html-assume-codepage $charset "$@"
if [ $? -ne 0 ]; then
    links -dump -html-numbered-links 1 -html-images 1  "$@"
    if [ $? -ne 0 ]; then
        cat "$@"
    fi
fi
