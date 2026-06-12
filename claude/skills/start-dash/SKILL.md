---
name: "start-dash"
description: "Use when the user wants to start the Mergify dashboard dev server against production data (cookie pulled from Chrome). Only valid inside a monorepo checkout — opens a new iTerm pane below the current one, runs `pnpm install && FRONT_API=... VITE_FRONT_API_COOKIE=$(cookies ...) pnpm start` from `<cwd>/dashboard/`. Triggers on `/start-dash`, \"start the dashboard\", \"start dash\"."
user_invocable: true
---

# start-dash

Launch the dashboard dev server in a new iTerm pane split below the current
pane.

## Guard: must be in a monorepo checkout

The skill is **only valid** when the current working directory is a monorepo
checkout (either `repos/monorepo/` or any worktree under
`projects/*/worktrees/*/`). Detection:

- `./dashboard/package.json` exists, AND
- `./engine/pyproject.toml` exists

If either is missing, abort with a clear message: "start-dash must run from
a monorepo checkout (need `./dashboard/` and `./engine/` siblings)". Do
**not** attempt to cd elsewhere — the spawned pane must run in the same
cwd as the caller.

## Steps

1. Resolve the caller's cwd (the cwd of the running `claude` session).
2. Verify the monorepo guard above. Bail if it fails.
3. Run the helper:
   ```bash
   bash "$HOME/.claude/skills/start-dash/start.sh" "<cwd>"
   ```
4. Confirm to the user that the pane was opened.

## What the helper does

The helper script (`start.sh`) drives iTerm via `osascript`:

- Splits the current iTerm session **horizontally** (creating a new pane
  below) using the default profile.
- In the new pane, runs:
  ```bash
  cd <cwd>/dashboard && pnpm install && \
    FRONT_API=https://dashboard.mergify.com \
    VITE_FRONT_API_COOKIE="$(cookies https://dashboard.mergify.com mergify-session)" \
    pnpm start
  ```
- The `cookies` helper (`~/.bin/cookies`) reads the `mergify-session`
  cookie from the user's Chrome profile so the dev server can talk to
  the production backend without re-authenticating.

## Notes

- The split inherits the user's default iTerm profile (same shell, same
  env). `~/.bin` is assumed to be on `PATH` so `cookies` resolves.
- The cookie is captured at launch time. If it expires, restart the pane
  (Ctrl+C, rerun `/start-dash`) to grab a fresh one.
- The skill does not check whether a dashboard dev server is already
  running — the user can run it more than once if they want a second pane.
- macOS / iTerm2 only. The AppleScript path doesn't work in tmux, Terminal
  .app, or non-mac environments — if the user runs this elsewhere it will
  fail loudly from `osascript`.
