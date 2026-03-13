#!/usr/bin/env bash
# Write Claude session status to ~/.claude/current-step/<session-id>/status
# Usage: called by Claude Code hooks with status as $1
# Receives JSON on stdin with session_id

STATUS="${*:-working}"

INPUT=$(cat)

if ! command -v jq >/dev/null 2>&1; then
    exit 0
fi

if ! SESSION_ID=$(echo "$INPUT" | jq -er '.session_id // empty' 2>/dev/null); then
    exit 0
fi

STATUS_DIR="$HOME/.claude/current-step/$SESSION_ID"
mkdir -p "$STATUS_DIR"
echo "$STATUS" > "$STATUS_DIR/status"

# Update iTerm2 tab color and title immediately for instant visual feedback
source "$(dirname "$0")/iterm2-helpers.sh"
iterm2_set_tab_color "$STATUS"

# Also update the tab title if a base title was saved by the statusline
BASE_TITLE_FILE="$STATUS_DIR/base_title"
if [ -f "$BASE_TITLE_FILE" ]; then
    BASE_TITLE=$(cat "$BASE_TITLE_FILE")
    EMOJI=$(iterm2_status_emoji "$STATUS")
    iterm2_set_tab_title "${EMOJI} ${BASE_TITLE}: ${STATUS}"
fi

exit 0
