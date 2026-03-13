#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract data from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
output_style=$(echo "$input" | jq -r '.output_style.name // empty')
agent=$(echo "$input" | jq -r '.agent.name // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')

# Shorten home directory to ~
cwd="${cwd/#$HOME/~}"

# Get git branch (skip optional locks for performance)
branch=$(git -C "${cwd/#\~/$HOME}" symbolic-ref --short HEAD 2>/dev/null)

# Colors
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

# Get GitHub repo name from git remote (org/repo), fallback to basename
repo=$(git -C "${cwd/#\~/$HOME}" remote get-url origin 2>/dev/null | sed 's/\.git$//' | sed -E 's#.+[:/][^/]+/([^/]+)$#\1#')
title="${repo:-$(basename "$cwd")}"
# Build status line parts
parts=()

# Add directory (cyan)
parts+=("${CYAN}${cwd}${RESET}")

# Add git branch if in a git repo, with * for dirty tree
if [ -n "$branch" ]; then
    title="${title} | ${branch}"
    dirty=""
    if ! git -C "${cwd/#\~/$HOME}" diff --quiet 2>/dev/null || ! git -C "${cwd/#\~/$HOME}" diff --cached --quiet 2>/dev/null; then
        title="${title}*"
        dirty="${YELLOW}*${RESET}"
    fi
    parts+=("(${GREEN}${branch}${RESET}${dirty})")
fi

# Add model name
parts+=("[$model]")

# Add context remaining if available
if [ -n "$remaining" ]; then
    # Round to integer
    remaining_int=$(printf "%.0f" "$remaining")
    parts+=("{ctx:${remaining_int}%}")
fi

# Add output style if not default
if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
    parts+=("[${output_style}]")
fi

# Add agent name if present
if [ -n "$agent" ]; then
    parts+=("agent:${agent}")
fi

# Load shared iTerm2 helpers
source "$HOME/.claude/hooks/iterm2-helpers.sh"

# Add session status to title + iTerm2 tab color
session_status=""
if [ -n "$session_id" ]; then
    status_file="$HOME/.claude/current-step/$session_id/status"
    if [ -f "$status_file" ]; then
        session_status=$(cat "$status_file")
        emoji=$(iterm2_status_emoji "$session_status")
        title="${emoji} ${title}: ${session_status}"
    fi
fi

# Join parts with space and print
printf "%b" "${parts[*]}"

# Set iTerm2 tab title and color
printf "\n%s" "$title"

# Save base title (without status prefix) for hooks to reuse
if [ -n "$session_id" ]; then
    base_title="${repo:-$(basename "$cwd")}"
    [ -n "$branch" ] && base_title="${base_title} | ${branch}"
    echo "$base_title" > "$HOME/.claude/current-step/$session_id/base_title"
fi

iterm2_set_tab_title "$title"
iterm2_set_tab_color "${session_status:-}"
