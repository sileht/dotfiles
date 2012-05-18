#!/bin/bash

charset=$1
shift

exec links -dump -html-numbered-links 1 -html-images 1 -html-assume-codepage $charset "$@"
