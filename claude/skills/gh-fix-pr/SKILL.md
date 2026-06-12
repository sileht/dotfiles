---
name: gh-fix-pr
description: Use to assess the WHOLE state of a GitHub PR (merge state, CI, review threads, merged-or-not) in one pass and take the next action — fix failing CI, address review threads, rebase a conflicted branch, narrate a resume while it waits on approval/merge, or declare it merged. Merges the old gh-fix-pr (fix) and p-resume-pr (watch) into one decision skill. Triggers on "/gh-fix-pr", "fix this PR", "address this PR", "what's the state of this PR", run after `mergify stack push`.
---

# Fix / assess PR (CI + reviews + merge state)

## Overview

One pass gathers the **whole** picture of a PR and decides the next thing
to do (or to just wait):

- merge state (conflicts / behind base → needs rebase),
- merged-or-not + overall CI verdict + review verdict (`state` block),
- failing GitHub Actions checks (with log snippets),
- unresolved review threads (with author + first comment).

`inspect_pr.py` returns all of it in one call. You read the `state` block,
branch into one of four actions, act, and stop. The `/p-loop-pr` monitor
re-invokes this skill whenever the PR next needs attention, so this skill
**never loops itself** — it acts once and returns.

External (non-GitHub-Actions) check providers are reported by URL only.

## Inputs

- `repo`: path inside the repo (default `.`)
- `pr`: PR number or URL (optional; defaults to current branch PR via
  `mergify stack list --json`, then `gh pr view`)
- `mode`: optional — `all` (default), `ci`, or `reviews`. Use this when the
  user has scoped the request (e.g. "just fix CI").

## Quick start

- `python3 ~/.claude/skills/gh-fix-pr/scripts/inspect_pr.py --repo "." --pr "<number-or-url>" --stack-list`
- Add `--json` for machine-readable output.
- `--mode ci` or `--mode reviews` to limit the inspection.
- `--signal` for the cheap one-line verdict the `/p-loop-pr` monitor polls.

## Workflow

### 1. Verify gh auth & resolve PR

- `gh auth status` — ask user to `gh auth login` (repo + workflow scopes) if not authenticated.
- Resolve PR:
  - Prefer `mergify stack list --json` (top entry's `pull_number`).
  - Fallback to `gh pr view --json number,url`.
  - If the user passes a PR number/URL, use it directly.

### 2. Inspect (single call covers everything)

Run `inspect_pr.py` with `--stack-list` so the verbatim `mergify stack list`
block is included (you surface it to the user as-is in the wait branch):

```bash
python3 ~/.claude/skills/gh-fix-pr/scripts/inspect_pr.py --repo "." --pr "<P>" --stack-list --json
```

The payload:

```jsonc
{
  "pr": "12345",
  "state": {                        // the high-level decision signals
    "merged": false,
    "ci": "failing",                // passing | failing | pending | none | unknown
    "reviews": "approved",          // approved | changes_requested | review_required | none
    "needsRebase": false,
    "mergeStateStatus": "BLOCKED",
    "headSha": "abc123...",
    "url": "https://github.com/.../pull/12345"
  },
  "mergeStatus": { "needsRebase": false, "mergeable": "MERGEABLE", "mergeStateStatus": "CLEAN" },
  "ci": { "target_pr": "12345", "inspected_pr": "12345", "failing": [ { "name": ..., "logSnippet": ... } ] },
  "reviews": { "threads": [ { "threadId": "...", "firstCommentId": 123, "path": "...", "line": 42,
                             "author": "...", "body": "...", "diffHunk": "...", "isOutdated": false } ] }
}
```

### 3. Branch on `state` — pick exactly one action

Read `state` and decide:

| Condition | Action |
|---|---|
| `state.merged == true` | **DONE** — §7 |
| `state.needsRebase == true` (or `mergeStatus.needsRebase`) | **REBASE** — §4 |
| `ci == "failing"` OR unresolved threads OR `reviews == "changes_requested"` | **FIX** — §5–6 |
| otherwise (pending/passing/approved, no threads, not merged) | **WAIT** — §8 |

Handle REBASE before FIX (a conflicted branch can't merge and may reorder the
CI picture). After a rebase+push, the monitor re-fires when CI lands.

### 4. REBASE (conflicts / branch behind base)

**Auto-fix policy:** a plain *behind base* (`mergeStateStatus == BEHIND`, no
conflicts) is obvious — rebase it without asking. A *conflicting* branch
(`mergeable == CONFLICTING` / `mergeStateStatus == DIRTY`) is a judgment call —
tell the user and confirm before rewriting the commit.

From inside the worktree:

```bash
git fetch origin <base>
git rebase origin/<base>
```

Resolve any conflicts. When a conflict involves code your PR modified *but* the
conflicting line was deleted on `main`, accept the deletion (your PR's change
is moot). Use `git log -p <base>..HEAD -- <file>` to see what your commit did.
Then `git add <files>` + `git rebase --continue`. Re-run affected tests,
`git check`, `mergify stack push`. Re-run `inspect_pr.py`.

### 5. Summarize + classify (FIX)

Present a single report. Lead with the merge-status line when `needsRebase`.

```
## PR #NNNNN — ci=<x> reviews=<y>

### Failing CI (N)
- **<check>** — <workflow> — <run url>
  Snippet (last failure marker):
    <log snippet>

### Unresolved review threads (N)
#### Pertinent (M)
1. **[file.py:L42]** @reviewer — "<summary>"  → Recommendation: <how to fix>
#### Non-pertinent (M)
1. **[file.py:L10]** @reviewer — "<summary>"  → Why: nit / style / question
```

Classification of review threads:

- **PERTINENT** — requires a code change: bug, logic error, security, missing
  edge case, wrong behavior, measurable perf issue.
- **NON-PERTINENT** — style, naming, questions, praise, cosmetic.

**Auto-fix policy (the answer to "Fix autonomy"):**

- **Auto-apply without asking** the obvious, low-judgment fixes: lint /
  formatting, an unambiguous CI fix the snippet points straight at, a needed
  *behind-base* rebase, and an all-flaky rerun (see below).
- **Ask via `AskUserQuestion`** only for the judgment calls: a pertinent
  *human* review thread that needs a design decision, or a CI failure whose
  fix is ambiguous / could go several ways. Surface those as the choices;
  non-pertinent items are shown for visibility only.
- If everything actionable is obvious, just fix it and report what you did —
  don't manufacture a question.

#### Dequeued PRs (CI side)

`inspect_pr.py` handles the "PR is in merge queue and the queued draft's CI
failed" case automatically: a `dequeued`-labelled PR is redirected to the last
failing queue draft. `target_pr` stays the original; `inspected_pr` is the
draft. **The fix still goes into the original PR's commit** (§6). If the last
queue status is not `❌ **Checks failed`, the script reports it and skips.

#### Flaky-test reruns

When every `failing[]` entry is tagged `likelyFlaky`, a rerun is the obvious
move — trigger it without asking:

```bash
python3 ~/.claude/skills/gh-fix-pr/scripts/inspect_pr.py --repo "." --pr "<NUM>" --rerun-flaky --json
```

The script reruns only when *all* failures match a flaky pattern; if any
failure looks real it refuses and lists the non-flaky checks under
`rerun.nonFlakyChecks` — investigate those normally. Do not loop reruns: a
"flaky" pattern recurring across runs is a real failure.

### 6. Implement, commit into the correct stack commit, push (FIX)

For each selected item: read surrounding code, apply the fix, run linters on
modified files (`uv run pre-commit run --show-diff-on-failure --files
<changed-files>`), fix any linter issues.

**Fixes (CI and review) MUST go into the commit associated with the PR — i.e.
`target_pr`, not the queue draft, and not HEAD by default.**

1. `mergify stack list` to map PR numbers to commit SHAs.
2. The target commit is the one whose PR number matches the PR being fixed.
3. **Do NOT use `git log -- <file>`** — a file may be touched by multiple
   commits; the fix belongs to the PR's commit.
4. Stage + fixup:
   ```bash
   git add <all-changed-files>
   git commit --fixup=<target-sha>
   GIT_SEQUENCE_EDITOR=: git rebase --autosquash origin/main
   ```
5. Run `/code-review max` and `git check` (both required before pushing per
   global rules). If `git check` leaves unstaged changes, stage + amend again.
6. `mergify stack push`.

**Shortcut:** if the target commit is HEAD, `git commit --amend --no-edit`.

Then **reply + resolve on GitHub** (review threads only). For each *fixed*
thread:

```bash
gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments \
  -f body="Fixed: <brief explanation>" -F in_reply_to=<firstCommentId>
```

`firstCommentId` is `databaseId` from the output. Resolution rules:

- **Copilot** (`copilot-pull-request-reviewer[bot]`) fixed or non-pertinent → resolve.
- **Human** fixed → reply, then `AskUserQuestion` (per thread or "all") whether
  to resolve. Default: leave unresolved.
- **Human** non-pertinent → no action. **Not fixed** → no action.

Resolve via GraphQL:

```bash
gh api graphql -f query='mutation($threadId: ID!){ resolveReviewThread(input:{threadId:$threadId}){ thread { isResolved } } }' -f threadId=<threadId>
```

After pushing, the `/p-loop-pr` monitor re-fires when CI reruns on the new SHA.
Report what was fixed and what is still outstanding, then stop.

### 7. DONE (merged)

`state.merged == true`: the PR is merged. Give the user the PR link and a
one-line "merged ✅". Then **stop the babysit monitor** so it doesn't keep
polling a merged PR:

- `TaskList` → find the background monitor whose description names this PR
  (e.g. `PR #<P> babysit`). `TaskStop` it if present.

Nothing else to do — stop.

### 8. WAIT (clean, not merged — the old p-resume-pr narration)

The PR is green-or-pending and just waiting on CI / an approval / the merge
queue. There is nothing to fix. Do two things:

1. **Surface the verbatim `mergify stack list` block** (the `===== mergify
   stack list =====` section from the `--stack-list` output) to the user
   **as-is** — do not parse or reformat that table.
2. Below it, write a **short prose resume**:
   - *Done so far:* stack pushed; current CI / review state (from `state`).
   - *Next steps:* what blocks merge right now (e.g. "waiting on 1 more
     approval", "CI still running", "ready — queued for merge").
   Keep it to a few lines. If the worktree's project `resume.md` is reachable
   and the user expects it updated, update its done/left section too.
3. **Ensure the PR is being babysat:** if no background monitor is watching
   this PR (`TaskList` shows none named `PR #<P> babysit`), invoke `/p-loop-pr`
   via the Skill tool to arm it. If one already exists, leave it.

Then stop. The monitor will re-invoke this skill when the PR next needs
attention, or notify you when it merges.

## Important notes

- **Act once, never loop.** The cadence belongs to the `/p-loop-pr` monitor.
- One plan == one branch == one commit per PR; never spray fixes across
  multiple stack commits.
- The report must be concise — summarize long comments, don't reproduce them.
- Push *before* replying on GitHub so the reply references pushed code.
- `merged=unknown` is **not** merged — treat as wait, keep watching.
- Approved + green is **not** merged (merge queue / branch protection) — wait.
- Treat non-GitHub-Actions checks as external: report the URL, don't fetch.

## Bundled resources

### scripts/inspect_pr.py

Unified inspection: whole-PR `state` (merged / ci / reviews / needsRebase),
failing checks with log snippets + queue-draft redirect, and unresolved review
threads — in one call. Exits non-zero when failing checks, unresolved threads,
or a needed rebase remain (so the legacy `/p-loop-pr` exit-code contract still
works). Extra modes:

- `--stack-list` — prepend the verbatim `mergify stack list` block (WAIT narration).
- `--signal` — print one `SIGNAL pr=... ci=... reviews=... action=fix|wait|done|unknown`
  line, no log fetching. Polled by the `/p-loop-pr` monitor to decide when to
  wake the agent.
