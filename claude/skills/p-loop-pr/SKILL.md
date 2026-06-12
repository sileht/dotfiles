---
name: p-loop-pr
description: Use when the user wants to babysit a single PR's stack to merge without polling noise. Arms a persistent Claude Monitor that watches the PR and stays silent while it is merely waiting (pending CI, waiting on an approval). It wakes the agent ONLY when the PR needs attention (failing CI, unresolved review threads, changes requested, needs rebase) — then you run /gh-fix-pr — and notifies once when the PR merges. No crons. Runs inside the PR's worktree. Triggers on "/p-loop-pr", "babysit this PR", "watch this PR to merge", "keep fixing this PR until green".
user_invocable: true
---

# p-loop-pr

Babysit one PR's stack to merge with a **single persistent Monitor** — no
crons. The monitor polls the PR's whole-state signal and emits a chat event
**only when something actionable changes**, so the agent's context is not
polluted on every tick when nothing has changed.

```
/p-loop-pr ──arm──▶ Monitor (polls SIGNAL every 90s, silent while "wait")
                        │
        action=fix /    │   action=done
   unresolved-change    │
                        ▼
                  emit one line ───▶ agent wakes ───▶ /gh-fix-pr   (fix → push)
                        │                                  │ push → CI reruns
                        │◀─────────── stays armed ─────────┘
                        ▼
                  action=done ───▶ emit "merged ✅", monitor exits ───▶ stop
```

The split of labor:

- **This skill** owns the *cadence* — one background monitor, armed once.
- **`/gh-fix-pr`** owns the *decision + the fix* — it assesses the whole state
  and acts once each time the monitor wakes it.

## When to use

- "Babysit / watch this PR to merge."
- Invoked by `/gh-fix-pr`'s WAIT branch to arm the watch after a push.

**Run from inside the PR's worktree**, not the manager root — the monitor
calls `mergify stack list` / `gh`, which need the worktree.

## Steps

### 1. Guard + resolve the PR

```bash
mergify stack list --json
```

- If it errors or has no `entries[0].pull_number`, abort: tell the user to run
  this from the PR's worktree (a checkout with a pushed stack). Arm nothing.
- Otherwise capture `P = entries[0].pull_number`.

### 2. Short-circuit if already merged

```bash
gh pr view <P> --json state,mergedAt
```

If `state == MERGED` (or `mergedAt` set): nothing to babysit. `TaskList` →
`TaskStop` any existing `PR #<P> babysit` monitor, tell the user it's merged,
stop.

### 3. Don't double-arm

`TaskList`. If a background task whose description is `PR #<P> babysit` is
already running, keep it — do **not** arm a second one. Report that the watch
is already active and stop.

### 4. Arm the persistent monitor

Call the `Monitor` tool with `persistent: true` and this command, **with
`<P>` replaced by the real PR number**:

```bash
SCRIPT="$HOME/.claude/skills/gh-fix-pr/scripts/inspect_pr.py"
prev=""
while true; do
  sig=$(python3 "$SCRIPT" --repo . --pr <P> --signal 2>/dev/null | grep '^SIGNAL' | tail -1) || true
  if [ -z "$sig" ]; then sleep 90; continue; fi
  action=$(printf '%s\n' "$sig" | sed -n 's/.*action=\([a-z]*\).*/\1/p')
  pr=$(printf '%s\n' "$sig" | sed -n 's/.* pr=\([0-9]*\).*/\1/p')
  case "$action" in
    done)
      echo "PR #$pr merged ✅ — run /gh-fix-pr to confirm, then the watch is done"
      break ;;
    unknown)
      sleep 90; continue ;;
    fix)
      if [ "$sig" != "$prev" ]; then
        echo "PR #$pr needs attention — run /gh-fix-pr  [$sig]"
      fi ;;
  esac
  prev="$sig"
  sleep 90
done
```

- `description`: `PR #<P> babysit` (TaskList uses it; keep it exact so step 3
  can dedup).
- `persistent`: `true`. `timeout_ms`: pass `3600000` (ignored when persistent).

Why this is quiet: the loop only `echo`s — i.e. only produces a chat event —
when `action` is `fix` **and the signal changed** (`$sig != $prev`), or when
the PR merges. A `wait` tick (pending CI, waiting on approval) produces no
output, so it costs zero context. The signal embeds the head SHA and an
unresolved-thread hash, so a re-push or a new review comment re-fires, but the
*same* failing state on the *same* SHA does not spam.

### 5. Tell the user, then yield

Report: the PR is being babysat by a background monitor; you'll run
`/gh-fix-pr` automatically when it needs attention, and stop when it merges.
Then end the turn — there is nothing to poll.

## Reacting to monitor events

The monitor's stdout lines arrive as chat notifications. They are **not** user
messages; act on them per their content:

- **`... needs attention — run /gh-fix-pr [SIGNAL ...]`** → invoke `/gh-fix-pr`
  via the Skill tool for this PR. Let it assess + act once (fix CI / address
  threads / rebase), commit into the stack commit, `mergify stack push`. The
  monitor stays armed; after the push, CI reruns and the next real failure (new
  SHA) re-fires. Do not re-arm anything.
- **`... merged ✅ ...`** (monitor then exits) → the PR is merged. Optionally
  run `/gh-fix-pr` to confirm + print the final resume. The watch is complete;
  nothing left to arm. (`TaskList` should now show the monitor gone.)

## Notes & gotchas

- **One monitor per PR.** Step 3's exists-check is load-bearing — without it a
  second `/p-loop-pr` would arm a duplicate watcher.
- **Silence is intended.** No event ≠ stuck. While CI runs or the PR waits on
  an approval, the monitor is deliberately quiet.
- **`unknown` ≠ done.** A transient `gh`/`mergify` hiccup yields
  `action=unknown`; the loop sleeps and retries. Only an explicit
  `action=done` (merged) stops it.
- **Approved + green ≠ merged.** Merge queue / branch protection can hold a
  green, approved PR. The monitor keeps watching until `merged`.
- **Stopping early.** `TaskList` → `TaskStop` the `PR #<P> babysit` task. The
  monitor also dies when this `claude` session exits (it is session-scoped).
- **Manager root is the wrong place.** No stack there → step 1 aborts. This
  skill is for worktree sessions only.
