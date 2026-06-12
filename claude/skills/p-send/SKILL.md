---
name: p-send
description: Use when the user wants to queue a new piece of work (fix or implement something) from any session, without leaving the current context. Drafts a plan file under the manager workspace's `projects/plans/`, then signals the top-level Manager iTerm tab to run `/p-new <plan>` so a fresh sub-claude is spawned to execute it.
user-invocable: true
argument-hint: <description of the work to plan>
---

# p-send

Drafts a plan from the user's description, writes it under the manager
workspace, and hands it off to the running Manager session so `/p-new`
spawns the worktree + sub-claude in a new iTerm tab.

This is the "throw a task over the wall" entry point — invoke it from any
session (a worktree sub-claude, the support tab, anywhere) when you notice
something that should become its own branch / PR but doesn't belong in the
current work.

## Inputs

- A short description of what to fix or implement, passed as arguments to
  `/p-send`. If nothing is passed, ask the user.

## Steps

1. **Confirm scope with the user.** Mirror the standard `/p-new` intake:
   - Which repo? (`monorepo`, `mergify-cli`, or another submodule under
     `/Users/sileht/workspace/mergify/manager/repos/`.)
   - Branch name? (No `sileht/` prefix.)
   - Does this need a Linear ticket? Ask every time — don't infer from
     commit type. Two valid answers:
     1. *Yes* → user provides MRGFY-XXXX, or asks you to create one (file
        in Linear, move to *Todo*, assign to the user).
     2. *No* → set `linear: []` in the frontmatter.
   - For feature work (not bugfix): also ask about docs and changelog
     before drafting.
2. **Draft the plan.** Write it to
   `/Users/sileht/workspace/mergify/manager/projects/plans/<plan-name>.md`
   with the standard frontmatter:
   ```yaml
   ---
   project: <project-name>
   repo: <repo>
   branch: <branch>
   base: origin/main                # optional
   linear: [MRGFY-XXXX]             # or [] to opt out
   ---

   # Goal
   ...

   # Steps
   ...

   # Acceptance criteria
   ...
   ```
   Show the drafted plan to the user and get confirmation before sending.
3. **Hand off to Manager.** Run the launcher:
   ```bash
   /Users/sileht/workspace/mergify/manager/bin/send.py <absolute-plan-path>
   ```
   The script will:
   - locate the claude process whose cwd is exactly
     `/Users/sileht/workspace/mergify/manager` (the Manager tab — not a
     worktree sub-claude),
   - bring that iTerm tab to the front,
   - wait until the Manager session is idle (status bar reports `- done`),
   - type `/p-new <plan-relative-path>` + Enter into it.
4. Confirm to the user that the plan was written and dispatched.

## Notes

- The launcher refuses if no Manager session is found (i.e. there's no
  claude running with cwd exactly equal to the manager workspace). In
  that case, ask the user to start a Manager session first.
- The launcher refuses to type into a busy Manager (per the existing
  "positive idle signal" rule for `p-checks`). It waits up to 30s; if
  the Manager stays busy, it aborts rather than buffering keystrokes
  into a mid-turn prompt.
- The skill does NOT spawn the sub-claude itself — the Manager session
  receives the `/p-new` and runs its standard flow (which may ask its
  own clarifying questions). Don't duplicate that work here; just draft
  the plan and dispatch.
- Plans live under `projects/plans/` permanently, including completed
  ones. Pick a descriptive filename (kebab-case, matches the branch).
