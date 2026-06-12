#!/usr/bin/env bash
# start-dash helper: split the current iTerm pane horizontally and run the
# dashboard dev server in the new pane.
#
# Usage: start.sh <cwd>
#   <cwd> must be a monorepo checkout (contains ./dashboard and ./engine).

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <monorepo-cwd>" >&2
  exit 2
fi

CWD="$1"

if [[ ! -d "$CWD/dashboard" || ! -d "$CWD/engine" ]]; then
  echo "error: '$CWD' is not a monorepo checkout (missing ./dashboard or ./engine)" >&2
  exit 1
fi

# Resolve to an absolute path so cd in the new pane is unambiguous.
CWD_ABS="$(cd "$CWD" && pwd)"

# Command to run in the new pane. Single-quoted heredoc so $(...) expands
# in the spawned shell, not here — we want the cookie fetched at pane
# launch time, not at skill invocation time.
read -r -d '' PANE_CMD <<EOF || true
cd ${CWD_ABS@Q}/dashboard && pnpm install && FRONT_API=https://dashboard.mergify.com VITE_FRONT_API_COOKIE="\$(cookies https://dashboard.mergify.com mergify-session)" pnpm start
EOF

# AppleScript-escape the command (backslashes and double quotes).
escaped="${PANE_CMD//\\/\\\\}"
escaped="${escaped//\"/\\\"}"

osascript <<APPLESCRIPT
tell application "iTerm"
    activate
    tell current session of current window
        set newSession to (split horizontally with default profile)
        tell newSession
            write text "$escaped"
        end tell
    end tell
end tell
APPLESCRIPT
