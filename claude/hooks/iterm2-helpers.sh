#!/bin/bash
# Shared iTerm2 helper functions for Claude session status visualization
# Sourced by status-tracker.sh and statusline-command.sh

# Set iTerm2 tab color based on Claude session status
iterm2_set_tab_color() {
    local tab_color
    case "$1" in
        "started")
            tab_color="\033]6;1;bg;red;brightness;100\a\033]6;1;bg;green;brightness;100\a\033]6;1;bg;blue;brightness;180\a" ;;
        "working")
            tab_color="\033]6;1;bg;red;brightness;200\a\033]6;1;bg;green;brightness;150\a\033]6;1;bg;blue;brightness;50\a" ;;
        "need approval")
            tab_color="\033]6;1;bg;red;brightness;255\a\033]6;1;bg;green;brightness;165\a\033]6;1;bg;blue;brightness;0\a" ;;
        "done")
            tab_color="\033]6;1;bg;red;brightness;50\a\033]6;1;bg;green;brightness;200\a\033]6;1;bg;blue;brightness;80\a" ;;
        *)
            tab_color="\033]6;1;bg;*;default\a" ;;
    esac
    printf "%b" "$tab_color" > /dev/tty 2>/dev/null
}

# Set iTerm2 tab title
iterm2_set_tab_title() {
    printf "\033]0;%s\007" "$1" > /dev/tty 2>/dev/null
}

# Get status emoji prefix for tab title
iterm2_status_emoji() {
    case "$1" in
        "started")       printf "▶" ;;
        "working")       printf "⚙" ;;
        "need approval") printf "⏸" ;;
        "done")          printf "✓" ;;
        *)               printf "●" ;;
    esac
}
