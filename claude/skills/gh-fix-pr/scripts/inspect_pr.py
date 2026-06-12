#!/usr/bin/env python3
"""Inspect a GitHub PR for failing CI checks AND unresolved review threads.

Merges the inspection logic previously split between gh-fix-ci and
gh-address-reviews so a single call gives a unified picture of what
needs attention on a PR.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path
from shutil import which
from typing import Any, Iterable, Sequence

FAILURE_CONCLUSIONS = {
    "failure",
    "cancelled",
    "timed_out",
    "action_required",
}

FAILURE_STATES = {
    "failure",
    "error",
    "cancelled",
    "timed_out",
    "action_required",
}

FAILURE_BUCKETS = {"fail"}

FAILURE_MARKERS = (
    "error",
    "fail",
    "failed",
    "traceback",
    "exception",
    "assert",
    "panic",
    "fatal",
    "timeout",
    "segmentation fault",
)

# Substring → human label. A failure log matching any of these is heuristically
# treated as a flaky test that warrants a rerun before investigating. Keep
# entries narrow: a false positive here causes a wasted CI rerun on a real bug,
# not a correctness issue.
LIKELY_FLAKY_PATTERNS: tuple[tuple[str, str], ...] = (
    ("psycopg.errors.DeadlockDetected", "postgres deadlock"),
    ("DeadlockDetected", "deadlock detected"),
    ("connection reset by peer", "connection reset"),
    ("BrokenPipeError", "broken pipe"),
    ("Connection refused", "connection refused"),
    ("Temporary failure in name resolution", "DNS failure"),
    ("operation was canceled", "operation cancelled mid-run"),
    ("The runner has received a shutdown signal", "runner shutdown"),
    ("ECONNRESET", "ECONNRESET"),
)

DEFAULT_MAX_LINES = 160
DEFAULT_CONTEXT_LINES = 30
PENDING_LOG_MARKERS = (
    "still in progress",
    "log will be available when it is complete",
)


class GhResult:
    def __init__(self, returncode: int, stdout: str, stderr: str):
        self.returncode = returncode
        self.stdout = stdout
        self.stderr = stderr


def run_gh_command(args: Sequence[str], cwd: Path) -> GhResult:
    process = subprocess.run(
        ["gh", *args],
        cwd=cwd,
        text=True,
        capture_output=True,
    )
    return GhResult(process.returncode, process.stdout, process.stderr)


def run_gh_command_raw(args: Sequence[str], cwd: Path) -> tuple[int, bytes, str]:
    process = subprocess.run(
        ["gh", *args],
        cwd=cwd,
        capture_output=True,
    )
    stderr = process.stderr.decode(errors="replace")
    return process.returncode, process.stdout, stderr


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Inspect a GitHub PR for failing CI checks and unresolved review "
            "threads. Emits a unified report so a single pass can address both."
        ),
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("--repo", default=".", help="Path inside the target Git repository.")
    parser.add_argument(
        "--pr", default=None, help="PR number or URL (defaults to current branch PR)."
    )
    parser.add_argument(
        "--mode",
        choices=("all", "ci", "reviews"),
        default="all",
        help="Limit the inspection to CI checks, review threads, or both.",
    )
    parser.add_argument("--max-lines", type=int, default=DEFAULT_MAX_LINES)
    parser.add_argument("--context", type=int, default=DEFAULT_CONTEXT_LINES)
    parser.add_argument("--json", action="store_true", help="Emit JSON instead of text output.")
    parser.add_argument(
        "--signal",
        action="store_true",
        help=(
            "Cheap mode: print one machine-readable `SIGNAL ...` line summarising "
            "the whole PR state (merged / ci / reviews / unresolved threads / "
            "rebase) plus an `action=` verdict (fix | wait | done | unknown). "
            "No log fetching — meant to be polled by the /p-loop-pr monitor."
        ),
    )
    parser.add_argument(
        "--stack-list",
        action="store_true",
        help=(
            "Prepend the verbatim `mergify stack list` output (between markers) "
            "before the report. The skill surfaces this block to the user as-is."
        ),
    )
    parser.add_argument(
        "--rerun-flaky",
        action="store_true",
        help=(
            "If every failing check is heuristically classified as flaky "
            "(matches LIKELY_FLAKY_PATTERNS in its log), call `gh run rerun "
            "<run_id> --failed` for the relevant run(s) and exit 0. "
            "No-op when some failures look real or no failures are flaky."
        ),
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = find_git_root(Path(args.repo))
    if repo_root is None:
        print("Error: not inside a Git repository.", file=sys.stderr)
        return 1

    if not ensure_gh_available(repo_root):
        return 1

    pr_value = resolve_pr(args.pr, repo_root)
    if pr_value is None:
        if args.signal:
            # Keep the monitor poll loop alive: a transient resolve failure is
            # "unknown", never "done".
            print("SIGNAL pr=none merged=unknown ci=unknown reviews=unknown "
                  "threads=0 rthash=0 rebase=unknown action=unknown")
            return 0
        return 1

    # --signal: cheap whole-state summary for the /p-loop-pr monitor. No log
    # fetching — just the one-line verdict the poll loop branches on.
    if args.signal:
        print(build_signal(pr_value=pr_value, repo_root=repo_root))
        return 0

    if args.stack_list:
        render_stack_list(repo_root)

    ci_section: dict[str, Any] | None = None
    review_section: dict[str, Any] | None = None
    merge_status = collect_merge_status(pr_value=pr_value, repo_root=repo_root)
    overall = collect_overall_state(pr_value=pr_value, repo_root=repo_root)

    if args.mode in ("all", "ci"):
        ci_section = collect_ci(
            pr_value=pr_value,
            repo_root=repo_root,
            max_lines=max(1, args.max_lines),
            context=max(1, args.context),
        )

    if args.mode in ("all", "reviews"):
        review_section = collect_reviews(pr_value=pr_value, repo_root=repo_root)

    payload: dict[str, Any] = {
        "pr": pr_value,
        "state": overall,
        "mergeStatus": merge_status,
    }
    if ci_section is not None:
        payload["ci"] = ci_section
    if review_section is not None:
        payload["reviews"] = review_section

    if args.rerun_flaky and ci_section:
        rerun_outcome = rerun_if_all_flaky(ci_section, repo_root=repo_root)
        payload["rerun"] = rerun_outcome
        if rerun_outcome.get("triggered"):
            # The reruns are now in flight; treat the prior failures as
            # transient so the caller can stop here rather than acting on them.
            ci_section["failing"] = []

    if args.json:
        print(json.dumps(payload, indent=2))
    else:
        render_text(payload)

    has_ci_failures = bool(ci_section and ci_section.get("failing"))
    has_unresolved_threads = bool(review_section and review_section.get("threads"))
    has_conflict = bool(merge_status.get("needsRebase"))
    return 1 if (has_ci_failures or has_unresolved_threads or has_conflict) else 0


# ---------------------------------------------------------------------------
# Shared helpers
# ---------------------------------------------------------------------------


def find_git_root(start: Path) -> Path | None:
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        cwd=start,
        text=True,
        capture_output=True,
    )
    if result.returncode != 0:
        return None
    return Path(result.stdout.strip())


def ensure_gh_available(repo_root: Path) -> bool:
    if which("gh") is None:
        print("Error: gh is not installed or not on PATH.", file=sys.stderr)
        return False
    result = run_gh_command(["auth", "status"], cwd=repo_root)
    if result.returncode == 0:
        return True
    message = (result.stderr or result.stdout or "").strip()
    print(message or "Error: gh not authenticated.", file=sys.stderr)
    return False


def resolve_pr(pr_value: str | None, repo_root: Path) -> str | None:
    if pr_value:
        return str(pr_value)

    number = resolve_pr_from_mergify_stack(repo_root)
    if number:
        return number

    result = run_gh_command(["pr", "view", "--json", "number"], cwd=repo_root)
    if result.returncode != 0:
        message = (result.stderr or result.stdout or "").strip()
        print(message or "Error: unable to resolve PR.", file=sys.stderr)
        return None
    try:
        data = json.loads(result.stdout or "{}")
    except json.JSONDecodeError:
        print("Error: unable to parse PR JSON.", file=sys.stderr)
        return None
    number_val = data.get("number")
    if not number_val:
        print("Error: no PR number found.", file=sys.stderr)
        return None
    return str(number_val)


def resolve_pr_from_mergify_stack(repo_root: Path) -> str | None:
    if which("mergify") is None:
        return None
    result = subprocess.run(
        ["mergify", "stack", "list", "--json"],
        cwd=repo_root,
        text=True,
        capture_output=True,
    )
    if result.returncode != 0:
        return None
    try:
        decoder = json.JSONDecoder(strict=False)
        data = decoder.decode(result.stdout or "{}")
    except json.JSONDecodeError:
        return None
    entries = data.get("entries", [])
    if not entries:
        return None
    pull_number = entries[0].get("pull_number")
    if pull_number:
        return str(pull_number)
    return None


def fetch_repo_slug(repo_root: Path) -> str | None:
    result = run_gh_command(["repo", "view", "--json", "nameWithOwner"], cwd=repo_root)
    if result.returncode != 0:
        return None
    try:
        data = json.loads(result.stdout or "{}")
    except json.JSONDecodeError:
        return None
    name_with_owner = data.get("nameWithOwner")
    if not name_with_owner:
        return None
    return str(name_with_owner)


def normalize_field(value: Any) -> str:
    if value is None:
        return ""
    return str(value).strip().lower()


def collect_merge_status(pr_value: str, repo_root: Path) -> dict[str, Any]:
    """Fetch the PR's merge state. ``needsRebase`` is True iff the PR is in a
    state the user must resolve locally (conflicting, or behind the base
    branch). ``error`` is set if the fetch failed."""
    status: dict[str, Any] = {"needsRebase": False}
    result = run_gh_command(
        ["pr", "view", str(pr_value), "--json", "mergeable,mergeStateStatus"],
        cwd=repo_root,
    )
    if result.returncode != 0:
        status["error"] = (result.stderr or result.stdout or "").strip()
        return status
    try:
        data = json.loads(result.stdout or "{}")
    except json.JSONDecodeError:
        status["error"] = "unable to parse merge status JSON"
        return status
    mergeable = data.get("mergeable")
    merge_state_status = data.get("mergeStateStatus")
    status["mergeable"] = mergeable
    status["mergeStateStatus"] = merge_state_status
    # CONFLICTING / DIRTY → rebase + resolve conflicts.
    # BEHIND → rebase only (no conflicts, just stale).
    if mergeable == "CONFLICTING" or merge_state_status in ("DIRTY", "BEHIND"):
        status["needsRebase"] = True
        status["reason"] = (
            "conflicts with base branch"
            if mergeable == "CONFLICTING" or merge_state_status == "DIRTY"
            else "branch is behind base"
        )
    return status


# ---------------------------------------------------------------------------
# Whole-PR state (merged / ci / reviews) + monitor signal
# ---------------------------------------------------------------------------

# Rollup classification — mirrors the conclusions GitHub reports on check runs
# (conclusion) and legacy commit statuses (state).
ROLLUP_FAIL = {"FAILURE", "ERROR", "CANCELLED", "TIMED_OUT", "ACTION_REQUIRED", "STARTUP_FAILURE"}
ROLLUP_PENDING = {"QUEUED", "IN_PROGRESS", "PENDING", "WAITING", "REQUESTED", "EXPECTED"}

OVERALL_FIELDS = [
    "state",
    "mergedAt",
    "reviewDecision",
    "statusCheckRollup",
    "mergeable",
    "mergeStateStatus",
    "url",
    "headRefOid",
]


def classify_rollup(rollup: list[dict[str, Any]] | None) -> str:
    """Reduce a statusCheckRollup to one of passing|failing|pending|none."""
    if not rollup:
        return "none"
    pending = False
    for check in rollup:
        conclusion = (check.get("conclusion") or "").upper()
        status = (check.get("status") or "").upper()
        # Commit statuses (vs check runs) report under "state".
        state = (check.get("state") or "").upper()
        if conclusion in ROLLUP_FAIL or state in {"FAILURE", "ERROR"}:
            return "failing"
        if status in ROLLUP_PENDING or state == "PENDING":
            pending = True
    return "pending" if pending else "passing"


def collect_overall_state(pr_value: str, repo_root: Path) -> dict[str, Any]:
    """One `gh pr view` reduced to the high-level decision signals: is it
    merged, what is CI doing overall, what is the review verdict, does it need a
    rebase. This is the picture the agent branches on (fix / wait / done)."""
    state: dict[str, Any] = {
        "merged": False,
        "ci": "unknown",
        "reviews": "unknown",
        "needsRebase": False,
        "headSha": "",
        "url": "",
    }
    result = run_gh_command(
        ["pr", "view", str(pr_value), "--json", ",".join(OVERALL_FIELDS)],
        cwd=repo_root,
    )
    if result.returncode != 0:
        state["error"] = (result.stderr or result.stdout or "").strip()
        return state
    try:
        data = json.loads(result.stdout or "{}")
    except json.JSONDecodeError:
        state["error"] = "unable to parse PR state JSON"
        return state

    merge_state_status = data.get("mergeStateStatus")
    mergeable = data.get("mergeable")
    state["merged"] = bool(data.get("state") == "MERGED" or data.get("mergedAt"))
    state["ci"] = classify_rollup(data.get("statusCheckRollup"))
    state["reviews"] = (data.get("reviewDecision") or "none").lower() or "none"
    state["mergeStateStatus"] = merge_state_status
    state["mergeable"] = mergeable
    state["needsRebase"] = bool(
        mergeable == "CONFLICTING" or merge_state_status in ("DIRTY", "BEHIND")
    )
    state["headSha"] = (data.get("headRefOid") or "")[:12]
    state["url"] = data.get("url") or ""
    return state


def unresolved_thread_signature(pr_value: str, repo_root: Path) -> tuple[int, str]:
    """(count, short-hash) of unresolved review-thread ids. The hash lets the
    monitor re-fire when a *new* review thread appears, even on the same SHA."""
    reviews = collect_reviews(pr_value=pr_value, repo_root=repo_root)
    if reviews.get("error"):
        return -1, "err"
    ids = sorted(t.get("threadId") or "" for t in reviews.get("threads") or [])
    if not ids:
        return 0, "0"
    digest = hashlib.sha1(",".join(ids).encode()).hexdigest()[:8]
    return len(ids), digest


def build_signal(pr_value: str, repo_root: Path) -> str:
    """Compute the one-line monitor signal. `action` is the verdict the poll
    loop branches on:

      done    -> merged; stop watching.
      fix     -> failing CI, unresolved threads, changes requested, or a needed
                 rebase; the PR needs hands-on attention.
      wait    -> green-or-pending and just waiting on CI / an approval / merge.
      unknown -> a fetch hiccuped; treat as wait (never as done).
    """
    overall = collect_overall_state(pr_value=pr_value, repo_root=repo_root)
    if overall.get("error"):
        return (
            f"SIGNAL pr={pr_value} merged=unknown ci=unknown reviews=unknown "
            f"threads=0 rthash=0 rebase=unknown action=unknown"
        )

    thread_count, rthash = unresolved_thread_signature(pr_value, repo_root)
    merged = overall["merged"]
    ci = overall["ci"]
    reviews = overall["reviews"]
    needs_rebase = overall["needsRebase"]

    if merged:
        action = "done"
    elif (
        needs_rebase
        or ci == "failing"
        or reviews == "changes_requested"
        or thread_count > 0
    ):
        action = "fix"
    else:
        action = "wait"

    return (
        f"SIGNAL pr={pr_value} sha={overall['headSha']} "
        f"merged={'true' if merged else 'false'} ci={ci} reviews={reviews} "
        f"threads={max(thread_count, 0)} rthash={rthash} "
        f"rebase={'true' if needs_rebase else 'false'} action={action}"
    )


def render_stack_list(repo_root: Path) -> None:
    """Print `mergify stack list` verbatim, between markers, for the user. The
    skill surfaces this block as-is (the resume narration) — it is not parsed."""
    if which("mergify") is None:
        print("(mergify CLI not found; skipping stack list)")
        return
    result = subprocess.run(
        ["mergify", "stack", "list"], cwd=repo_root, text=True, capture_output=True
    )
    print("===== mergify stack list =====")
    sys.stdout.write(result.stdout)
    if not result.stdout.endswith("\n"):
        print()
    if result.stderr:
        sys.stderr.write(result.stderr)
    print("==============================")


# ---------------------------------------------------------------------------
# CI section
# ---------------------------------------------------------------------------


def collect_ci(
    pr_value: str,
    repo_root: Path,
    max_lines: int,
    context: int,
) -> dict[str, Any]:
    section: dict[str, Any] = {"target_pr": pr_value, "failing": []}

    inspected_pr, redirect_note = maybe_redirect_to_queue_draft(pr_value, repo_root)
    if redirect_note:
        section["redirect_note"] = redirect_note
    if inspected_pr is None:
        # Redirected away but the queue comment said there's nothing actionable.
        return section
    section["inspected_pr"] = inspected_pr

    checks = fetch_checks(inspected_pr, repo_root)
    if checks is None:
        section["error"] = "unable to fetch checks"
        return section

    failing = [c for c in checks if is_failing(c)]
    if not failing:
        return section

    analyzed = []
    for check in failing:
        analyzed.append(
            analyze_check(
                check,
                repo_root=repo_root,
                max_lines=max_lines,
                context=context,
            )
        )
    section["failing"] = analyzed
    return section


def maybe_redirect_to_queue_draft(
    pr_value: str, repo_root: Path
) -> tuple[str | None, str | None]:
    """If the PR is dequeued, find the queue draft whose CI actually failed."""
    result = run_gh_command(
        ["pr", "view", pr_value, "--json", "labels,comments"], cwd=repo_root
    )
    if result.returncode != 0:
        return pr_value, None
    try:
        data = json.loads(result.stdout or "{}")
    except json.JSONDecodeError:
        return pr_value, None

    labels = {
        normalize_field(label.get("name"))
        for label in data.get("labels", [])
        if isinstance(label, dict)
    }
    if "dequeued" not in labels:
        return pr_value, None

    comments = [
        c
        for c in data.get("comments", [])
        if isinstance(c, dict)
        and (c.get("author") or {}).get("login") == "mergify[bot]"
        and (c.get("body") or "").startswith("# Merge Queue Status")
    ]
    if not comments:
        return pr_value, "PR is dequeued but no Merge Queue Status comment found."

    body = comments[-1].get("body", "")
    if "❌ **Checks failed" not in body:
        return None, "PR is dequeued but the last queue status is not a failure."

    draft_numbers = re.findall(
        r"✅ \*\*Checks started.*?on draft #(\d+)", body, flags=re.DOTALL
    )
    if not draft_numbers:
        return None, "Dequeued comment did not reference a draft PR number."

    draft_pr = draft_numbers[-1]
    note = (
        f"PR is dequeued; CI failures live on queue draft PR #{draft_pr}. "
        f"Fix the original PR's commit, not the draft."
    )
    return draft_pr, note


def fetch_checks(pr_value: str, repo_root: Path) -> list[dict[str, Any]] | None:
    primary_fields = ["name", "state", "conclusion", "detailsUrl", "startedAt", "completedAt"]
    result = run_gh_command(
        ["pr", "checks", pr_value, "--json", ",".join(primary_fields)],
        cwd=repo_root,
    )
    if result.returncode != 0:
        message = "\n".join(filter(None, [result.stderr, result.stdout])).strip()
        available_fields = parse_available_fields(message)
        if available_fields:
            fallback_fields = [
                "name",
                "state",
                "bucket",
                "link",
                "startedAt",
                "completedAt",
                "workflow",
            ]
            selected_fields = [field for field in fallback_fields if field in available_fields]
            if not selected_fields:
                print("Error: no usable fields available for gh pr checks.", file=sys.stderr)
                return None
            result = run_gh_command(
                ["pr", "checks", pr_value, "--json", ",".join(selected_fields)],
                cwd=repo_root,
            )
            if result.returncode != 0:
                message = (result.stderr or result.stdout or "").strip()
                print(message or "Error: gh pr checks failed.", file=sys.stderr)
                return None
        else:
            print(message or "Error: gh pr checks failed.", file=sys.stderr)
            return None
    try:
        data = json.loads(result.stdout or "[]")
    except json.JSONDecodeError:
        print("Error: unable to parse checks JSON.", file=sys.stderr)
        return None
    if not isinstance(data, list):
        print("Error: unexpected checks JSON shape.", file=sys.stderr)
        return None
    return data


def is_failing(check: dict[str, Any]) -> bool:
    conclusion = normalize_field(check.get("conclusion"))
    if conclusion in FAILURE_CONCLUSIONS:
        return True
    state = normalize_field(check.get("state") or check.get("status"))
    if state in FAILURE_STATES:
        return True
    bucket = normalize_field(check.get("bucket"))
    return bucket in FAILURE_BUCKETS


def analyze_check(
    check: dict[str, Any],
    repo_root: Path,
    max_lines: int,
    context: int,
) -> dict[str, Any]:
    url = check.get("detailsUrl") or check.get("link") or ""
    run_id = extract_run_id(url)
    job_id = extract_job_id(url)
    base: dict[str, Any] = {
        "name": check.get("name", ""),
        "detailsUrl": url,
        "runId": run_id,
        "jobId": job_id,
    }

    if run_id is None:
        base["status"] = "external"
        base["note"] = "No GitHub Actions run id detected in detailsUrl."
        return base

    metadata = fetch_run_metadata(run_id, repo_root)
    log_text, log_error, log_status = fetch_check_log(
        run_id=run_id,
        job_id=job_id,
        repo_root=repo_root,
    )

    if log_status == "pending":
        base["status"] = "log_pending"
        base["note"] = log_error or "Logs are not available yet."
        if metadata:
            base["run"] = metadata
        return base

    if log_error:
        base["status"] = "log_unavailable"
        base["error"] = log_error
        if metadata:
            base["run"] = metadata
        return base

    snippet = extract_failure_snippet(log_text, max_lines=max_lines, context=context)
    base["status"] = "ok"
    base["run"] = metadata or {}
    base["logSnippet"] = snippet
    base["logTail"] = tail_lines(log_text, max_lines)
    flaky_label = detect_flaky_pattern(snippet) or detect_flaky_pattern(log_text)
    if flaky_label:
        base["likelyFlaky"] = True
        base["flakyReason"] = flaky_label
    return base


def detect_flaky_pattern(text: str) -> str | None:
    if not text:
        return None
    for needle, label in LIKELY_FLAKY_PATTERNS:
        if needle in text:
            return label
    return None


def rerun_if_all_flaky(
    ci_section: dict[str, Any], repo_root: Path
) -> dict[str, Any]:
    """If every entry in ``ci_section['failing']`` carries ``likelyFlaky``,
    call ``gh run rerun <run_id> --failed`` for each distinct run and return a
    summary. Otherwise return why no rerun was attempted."""
    failing = ci_section.get("failing") or []
    if not failing:
        return {"triggered": False, "reason": "no failing checks"}

    not_flaky = [f for f in failing if not f.get("likelyFlaky")]
    if not_flaky:
        return {
            "triggered": False,
            "reason": (
                f"{len(not_flaky)} of {len(failing)} failing check(s) do not "
                "match a known flaky pattern; investigate manually."
            ),
            "nonFlakyChecks": [f.get("name", "") for f in not_flaky],
        }

    run_ids = sorted({f.get("runId") for f in failing if f.get("runId")})
    if not run_ids:
        return {
            "triggered": False,
            "reason": "no resolvable run id on failing checks",
        }

    reruns: list[dict[str, Any]] = []
    for run_id in run_ids:
        result = run_gh_command(
            ["run", "rerun", str(run_id), "--failed"], cwd=repo_root
        )
        reruns.append(
            {
                "runId": run_id,
                "ok": result.returncode == 0,
                "message": (result.stderr or result.stdout or "").strip(),
            }
        )

    triggered = any(r["ok"] for r in reruns)
    return {
        "triggered": triggered,
        "reason": (
            f"matched flaky pattern on {len(failing)} check(s); "
            f"rerun --failed on {len(run_ids)} run(s)"
        )
        if triggered
        else "gh run rerun command failed; see reruns[].message",
        "reruns": reruns,
    }


def extract_run_id(url: str) -> str | None:
    if not url:
        return None
    for pattern in (r"/actions/runs/(\d+)", r"/runs/(\d+)"):
        match = re.search(pattern, url)
        if match:
            return match.group(1)
    return None


def extract_job_id(url: str) -> str | None:
    if not url:
        return None
    match = re.search(r"/actions/runs/\d+/job/(\d+)", url)
    if match:
        return match.group(1)
    match = re.search(r"/job/(\d+)", url)
    if match:
        return match.group(1)
    return None


def fetch_run_metadata(run_id: str, repo_root: Path) -> dict[str, Any] | None:
    fields = [
        "conclusion",
        "status",
        "workflowName",
        "name",
        "event",
        "headBranch",
        "headSha",
        "url",
    ]
    result = run_gh_command(["run", "view", run_id, "--json", ",".join(fields)], cwd=repo_root)
    if result.returncode != 0:
        return None
    try:
        data = json.loads(result.stdout or "{}")
    except json.JSONDecodeError:
        return None
    if not isinstance(data, dict):
        return None
    return data


def fetch_check_log(
    run_id: str,
    job_id: str | None,
    repo_root: Path,
) -> tuple[str, str, str]:
    log_text, log_error = fetch_run_log(run_id, repo_root)
    if not log_error:
        return log_text, "", "ok"

    if is_log_pending_message(log_error) and job_id:
        job_log, job_error = fetch_job_log(job_id, repo_root)
        if job_log:
            return job_log, "", "ok"
        if job_error and is_log_pending_message(job_error):
            return "", job_error, "pending"
        if job_error:
            return "", job_error, "error"
        return "", log_error, "pending"

    if is_log_pending_message(log_error):
        return "", log_error, "pending"

    return "", log_error, "error"


def fetch_run_log(run_id: str, repo_root: Path) -> tuple[str, str]:
    result = run_gh_command(["run", "view", run_id, "--log"], cwd=repo_root)
    if result.returncode != 0:
        error = (result.stderr or result.stdout or "").strip()
        return "", error or "gh run view failed"
    return result.stdout, ""


def fetch_job_log(job_id: str, repo_root: Path) -> tuple[str, str]:
    repo_slug = fetch_repo_slug(repo_root)
    if not repo_slug:
        return "", "Error: unable to resolve repository name for job logs."
    endpoint = f"/repos/{repo_slug}/actions/jobs/{job_id}/logs"
    returncode, stdout_bytes, stderr = run_gh_command_raw(["api", endpoint], cwd=repo_root)
    if returncode != 0:
        message = (stderr or stdout_bytes.decode(errors="replace")).strip()
        return "", message or "gh api job logs failed"
    if is_zip_payload(stdout_bytes):
        return "", "Job logs returned a zip archive; unable to parse."
    return stdout_bytes.decode(errors="replace"), ""


def parse_available_fields(message: str) -> list[str]:
    if "Available fields:" not in message:
        return []
    fields: list[str] = []
    collecting = False
    for line in message.splitlines():
        if "Available fields:" in line:
            collecting = True
            continue
        if not collecting:
            continue
        field = line.strip()
        if not field:
            continue
        fields.append(field)
    return fields


def is_log_pending_message(message: str) -> bool:
    lowered = message.lower()
    return any(marker in lowered for marker in PENDING_LOG_MARKERS)


def is_zip_payload(payload: bytes) -> bool:
    return payload.startswith(b"PK")


def extract_failure_snippet(log_text: str, max_lines: int, context: int) -> str:
    lines = log_text.splitlines()
    if not lines:
        return ""

    marker_index = find_failure_index(lines)
    if marker_index is None:
        return "\n".join(lines[-max_lines:])

    start = max(0, marker_index - context)
    end = min(len(lines), marker_index + context)
    window = lines[start:end]
    if len(window) > max_lines:
        window = window[-max_lines:]
    return "\n".join(window)


def find_failure_index(lines: Sequence[str]) -> int | None:
    for idx in range(len(lines) - 1, -1, -1):
        lowered = lines[idx].lower()
        if any(marker in lowered for marker in FAILURE_MARKERS):
            return idx
    return None


def tail_lines(text: str, max_lines: int) -> str:
    if max_lines <= 0:
        return ""
    lines = text.splitlines()
    return "\n".join(lines[-max_lines:])


# ---------------------------------------------------------------------------
# Reviews section
# ---------------------------------------------------------------------------


REVIEW_THREADS_QUERY = """
query($owner: String!, $name: String!, $pr: Int!) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $pr) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          comments(first: 50) {
            nodes {
              id
              databaseId
              body
              author { login }
              path
              line
              originalLine
              diffHunk
              createdAt
            }
          }
        }
      }
    }
  }
}
"""


def collect_reviews(pr_value: str, repo_root: Path) -> dict[str, Any]:
    section: dict[str, Any] = {"threads": []}
    repo_slug = fetch_repo_slug(repo_root)
    if not repo_slug:
        section["error"] = "unable to resolve repository name for review threads"
        return section
    owner, _, name = repo_slug.partition("/")
    if not owner or not name:
        section["error"] = f"unexpected repo slug: {repo_slug}"
        return section

    result = run_gh_command(
        [
            "api",
            "graphql",
            "-f",
            f"query={REVIEW_THREADS_QUERY}",
            "-f",
            f"owner={owner}",
            "-f",
            f"name={name}",
            "-F",
            f"pr={pr_value}",
        ],
        cwd=repo_root,
    )
    if result.returncode != 0:
        section["error"] = (result.stderr or result.stdout or "graphql call failed").strip()
        return section
    try:
        data = json.loads(result.stdout or "{}")
    except json.JSONDecodeError:
        section["error"] = "unable to parse graphql JSON"
        return section

    nodes = (
        data.get("data", {})
        .get("repository", {})
        .get("pullRequest", {})
        .get("reviewThreads", {})
        .get("nodes", [])
    )
    threads: list[dict[str, Any]] = []
    for thread in nodes:
        if not isinstance(thread, dict):
            continue
        if thread.get("isResolved"):
            continue
        comments_nodes = (thread.get("comments") or {}).get("nodes") or []
        if not comments_nodes:
            continue
        first = comments_nodes[0]
        author = (first.get("author") or {}).get("login") or ""
        threads.append(
            {
                "threadId": thread.get("id"),
                "isOutdated": thread.get("isOutdated", False),
                "path": first.get("path"),
                "line": first.get("line") or first.get("originalLine"),
                "author": author,
                "firstCommentId": first.get("databaseId"),
                "body": first.get("body", ""),
                "diffHunk": first.get("diffHunk", ""),
                "commentCount": len(comments_nodes),
            }
        )
    section["threads"] = threads
    return section


# ---------------------------------------------------------------------------
# Text rendering
# ---------------------------------------------------------------------------


def render_text(payload: dict[str, Any]) -> None:
    pr = payload.get("pr", "?")
    print(f"PR #{pr}")
    if "state" in payload:
        render_overall_state(payload["state"])
    if "mergeStatus" in payload:
        render_merge_status(payload["mergeStatus"])
    if "ci" in payload:
        render_ci(payload["ci"])
    if "reviews" in payload:
        render_reviews(payload["reviews"])
    if "rerun" in payload:
        render_rerun(payload["rerun"])


def render_rerun(rerun: dict[str, Any]) -> None:
    if not rerun:
        return
    print("=" * 60)
    print("Flaky rerun")
    if rerun.get("triggered"):
        print(f"✓ {rerun.get('reason', '')}")
    else:
        print(f"Skipped: {rerun.get('reason', '')}")
    for entry in rerun.get("reruns") or []:
        status = "ok" if entry.get("ok") else "failed"
        msg = entry.get("message") or ""
        line = f"  run {entry.get('runId', '?')}: {status}"
        if msg:
            line += f" ({msg})"
        print(line)


def render_overall_state(state: dict[str, Any]) -> None:
    print("=" * 60)
    print("PR state")
    if state.get("error"):
        print(f"Error: {state['error']}")
        return
    merged = "yes" if state.get("merged") else "no"
    print(
        f"merged={merged} ci={state.get('ci', '?')} "
        f"reviews={state.get('reviews', '?')} "
        f"mergeState={state.get('mergeStateStatus') or '?'}"
    )
    if state.get("url"):
        print(f"url: {state['url']}")


def render_merge_status(status: dict[str, Any]) -> None:
    if status.get("error"):
        print("=" * 60)
        print("Merge status")
        print(f"Error: {status['error']}")
        return
    if not status.get("needsRebase"):
        return
    print("=" * 60)
    print("Merge status")
    mergeable = status.get("mergeable") or "?"
    merge_state = status.get("mergeStateStatus") or "?"
    reason = status.get("reason") or "branch needs rebase"
    print(f"⚠️  Needs rebase ({reason}); mergeable={mergeable}, "
          f"mergeStateStatus={merge_state}")
    print("Run `git fetch origin && git rebase origin/<base>` locally, "
          "resolve any conflicts, then `mergify stack push`.")


def render_ci(ci: dict[str, Any]) -> None:
    print("=" * 60)
    print("CI checks")
    if ci.get("redirect_note"):
        print(f"Note: {ci['redirect_note']}")
    inspected = ci.get("inspected_pr")
    if inspected and inspected != ci.get("target_pr"):
        print(f"Inspecting CI on PR #{inspected}.")
    if ci.get("error"):
        print(f"Error: {ci['error']}")
        return
    failing = ci.get("failing") or []
    if not failing:
        print("No failing checks.")
        return
    print(f"{len(failing)} failing check(s):")
    for result in failing:
        print("-" * 60)
        print(f"Check: {result.get('name', '')}")
        if result.get("detailsUrl"):
            print(f"Details: {result['detailsUrl']}")
        run_meta = result.get("run") or {}
        if run_meta:
            workflow = run_meta.get("workflowName") or run_meta.get("name") or ""
            conclusion = run_meta.get("conclusion") or run_meta.get("status") or ""
            if workflow or conclusion:
                print(f"Workflow: {workflow} ({conclusion})")
            if run_meta.get("url"):
                print(f"Run URL: {run_meta['url']}")
        print(f"Status: {result.get('status', 'unknown')}")
        if result.get("note"):
            print(f"Note: {result['note']}")
        if result.get("error"):
            print(f"Error fetching logs: {result['error']}")
            continue
        snippet = result.get("logSnippet") or ""
        if snippet:
            print("Failure snippet:")
            print(indent_block(snippet, prefix="  "))
        else:
            print("No snippet available.")
    print("-" * 60)


def render_reviews(reviews: dict[str, Any]) -> None:
    print("=" * 60)
    print("Review threads")
    if reviews.get("error"):
        print(f"Error: {reviews['error']}")
        return
    threads = reviews.get("threads") or []
    if not threads:
        print("No unresolved review threads.")
        return
    print(f"{len(threads)} unresolved thread(s):")
    for thread in threads:
        print("-" * 60)
        loc = thread.get("path") or "?"
        line = thread.get("line")
        loc = f"{loc}:{line}" if line else loc
        author = thread.get("author", "?")
        outdated = " (outdated)" if thread.get("isOutdated") else ""
        print(f"[{loc}] @{author}{outdated}")
        body = (thread.get("body") or "").strip()
        if body:
            print(indent_block(body, prefix="  "))
    print("-" * 60)


def render_results_legacy(pr_number: str, results: Iterable[dict[str, Any]]) -> None:
    """Preserved for backwards compatibility with older callers."""
    render_ci({"target_pr": pr_number, "inspected_pr": pr_number, "failing": list(results)})


def indent_block(text: str, prefix: str = "  ") -> str:
    return "\n".join(f"{prefix}{line}" for line in text.splitlines())


if __name__ == "__main__":
    raise SystemExit(main())
