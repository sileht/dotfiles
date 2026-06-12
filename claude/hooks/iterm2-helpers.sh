#!/bin/bash
# Shared iTerm2 helper functions for Claude session status visualization
# Sourced by status-tracker.sh and statusline-command.sh

# Set iTerm2 tab color based on Claude session status
iterm2_set_tab_color() {
    return
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

iterm2_set_tab() {
    # Also update the tab title if a base title was saved by the statusline
    session_id="$1"
    status_dir="$HOME/.claude/current-step/$session_id"

    title_file="$status_dir/title"
    subtitle_file="$status_dir/subtitle"
    status_file="$status_dir/status"

    title=$(cat "$title_file")
    subtitle=$(cat "$subtitle_file")
    status=$(cat "$status_file")
    emoji=$(iterm2_status_emoji "$status")

    tab_title="${emoji} ${title}"
    tab_title="${tab_title} - ${status}"
    # [ -n "${subtitle}" ] && tab_title="${tab_title}\n${subtitle}"

    iterm2_set_tab_color "$status"
    iterm2_set_tab_title "$tab_title"
    echo -e "$tab_title"
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
