---
name: standup
description: Use when the user asks for a standup summary, daily update, or wants to know what they worked on recently. Analyzes Claude session history and git logs to generate a structured standup report.
user_invocable: true
---

# Standup Summary Generator

Generate a standup summary by analyzing recent Claude Code sessions and git activity across all projects.

## Steps

### 1. Extract Recent Sessions from Claude History

Read `~/.claude/history.jsonl` and filter entries from yesterday and today. Group them by project and session.

```bash
python3 -c "
import json, datetime

today = datetime.date.today()
yesterday = today - datetime.timedelta(days=1)
start = datetime.datetime.combine(yesterday, datetime.time.min).timestamp() * 1000
end = datetime.datetime.combine(today + datetime.timedelta(days=1), datetime.time.min).timestamp() * 1000

sessions = {}
with open('$HOME/.claude/history.jsonl') as f:
    for line in f:
        try:
            entry = json.loads(line)
            ts = entry.get('timestamp', 0)
            if start <= ts <= end:
                sid = entry.get('sessionId', 'unknown')
                project = entry.get('project', 'unknown')
                display = entry.get('display', '')
                dt = datetime.datetime.fromtimestamp(ts/1000)
                date_str = dt.strftime('%Y-%m-%d %H:%M')
                if sid not in sessions:
                    sessions[sid] = {'project': project, 'messages': [], 'first': dt, 'last': dt}
                sessions[sid]['messages'].append(display)
                sessions[sid]['last'] = dt
        except:
            pass

for sid, info in sorted(sessions.items(), key=lambda x: x[1]['first']):
    proj = info['project'].replace('$HOME/workspace/', '').replace('/Users/$(whoami)/workspace/', '')
    first = info['first'].strftime('%Y-%m-%d %H:%M')
    last = info['last'].strftime('%Y-%m-%d %H:%M')
    print(f'=== {proj} ({first} -> {last}) ===')
    for msg in info['messages']:
        if msg:
            print(f'  - {msg[:150]}')
    print()
"
```

### 2. Get Git Commits for Active Projects

For each project directory that appeared in the sessions, retrieve recent commits:

```bash
git -C <project-dir> log --oneline --since="<yesterday-date>" --format="%h %s" | head -5
```

Do this for all project directories found in step 1. Use parallel execution when possible.

### 3. Synthesize Standup Report

Combine session context (user messages show intent and what was being worked on) with git commits (show actual deliverables) into a structured standup report:

```markdown
## Standup - <date range>

### Yesterday
- **project-name**: Brief description of what was done (reference commits and PR numbers)

### Today
- **project-name**: Brief description of what was done or is in progress

### Focus areas
- High-level themes across all work
```

## Guidelines

- Group related work by project/branch name
- Include PR numbers and Linear ticket IDs when visible in commits or messages
- Mention incident references (INC-xxx) if present
- Distinguish between completed work and in-progress work
- Keep descriptions concise - one line per project/branch
- Identify cross-cutting themes for the "Focus areas" section
- If a session only contains `/exit` or trivial messages, skip it
- Categorize by area when user works across multiple repos (e.g., Engine, UI, Infrastructure)
