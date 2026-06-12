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

# Keep original path for git operations
cwd_real="${cwd/#\~/$HOME}"

# Shorten path: keep last 2 dirs full, abbreviate others to first letter
shorten_path() {
    local path="$1"
    IFS='/' read -ra parts <<< "$path"
    local count=${#parts[@]}
    local result=""
    for ((i=0; i<count; i++)); do
        if [ $i -gt 0 ]; then
            result+="/"
        fi
        if [ $((count - i)) -le 2 ]; then
            result+="${parts[$i]}"
        elif [ "${parts[$i]}" = "~" ] || [ -z "${parts[$i]}" ]; then
            result+="${parts[$i]}"
        else
            result+="${parts[$i]:0:1}"
        fi
    done
    echo "$result"
}
cwd=$(shorten_path "$cwd")

# Get git branch (skip optional locks for performance)
branch=$(git -C "$cwd_real" symbolic-ref --short HEAD 2>/dev/null)

# Colors
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

# Get GitHub repo name from git remote (org/repo), fallback to basename
repo=$(git -C "$cwd_real" remote get-url origin 2>/dev/null | sed 's/\.git$//' | sed -E 's#.+[:/][^/]+/([^/]+)$#\1#')
title="${repo:-$(basename "$cwd")}"
# Build status line parts
parts=()

# Add directory (cyan)
parts+=("${CYAN}${cwd}${RESET}")

# Add git branch if in a git repo, with * for dirty tree
if [ -n "$branch" ]; then
    title="${title} | ${branch}"
    dirty=""
    if ! git -C "$cwd_real" diff --quiet 2>/dev/null || ! git -C "$cwd_real" diff --cached --quiet 2>/dev/null; then
        title="${title}*"
        dirty="${YELLOW}*${RESET}"
    fi
    parts+=("(${GREEN}${branch}${RESET}${dirty})")
fi

# Add model name
parts+=("[$model]")

# Add session cost if available
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$cost" ]; then
    parts+=("[${GREEN}$(printf '$%.2f' "$cost")${RESET}]")
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

# Join parts with space and print
printf "%b" "${parts[*]}"

# Save base title (without status prefix) for hooks to reuse
if [ -n "$session_id" ]; then
    title="${repo:-$(basename "$cwd")}"
    [ -n "$branch" ] && title="$title | $branch"
    subtitle=""
    #if [ -n "$branch" ]; then
    #    title="${branch}"
    #    subtitle="${cwd}"
    #else
    #    title="${cwd}"
    #    subtitle=":"
    #fi
    STATUS_DIR="$HOME/.claude/current-step/$session_id"
    mkdir -p "$STATUS_DIR"
    echo "$title" > "$STATUS_DIR/title"
    echo "$subtitle" > "$STATUS_DIR/subtitle"
    echo "$repo" > "$STATUS_DIR/repo"
    echo
    iterm2_set_tab "$session_id"
fi
exit 0
