
#!/usr/bin/env bash

set -u

echo "===== PHASE 719 FIND ACTIVE WORKER WRITER ====="

echo ""

echo "[1] Repo/runtime checkpoint"

pwd

git status --short

git log --oneline --decorate -6

docker compose ps

echo ""

echo "[2] Search active source for exact runtime strings"

python3 - << 'PY'

from pathlib import Path

skip = {".git", "node_modules", "dist", "build", ".next", "archive", "ts-backup", "backups"}

terms = [

    "Standard execution prepared for:",

    "standard execution path",

    "communicationResult",

    "outcome_preview",

    "execution_meta",

    "claimed_by",

    "completed_at",

    "worker-d",

    "TIER_1",

    "operator-safe outcome",

]

hits = []

for path in Path(".").rglob("*"):

    if any(part in skip for part in path.parts):

        continue

    if not path.is_file():

        continue

    if path.suffix.lower() not in {".js", ".mjs", ".ts", ".tsx", ".json", ".sh", ".md"}:

        continue

    try:

        text = path.read_text(errors="ignore")

    except Exception:

        continue

    matched = [term for term in terms if term in text]

    if matched:

        hits.append((str(path), matched))

print("MATCHING_FILES:")

for path, matched in hits[:80]:

    print(f"- {path} :: {', '.join(matched)}")

print("")

print("COUNT:", len(hits))

PY

echo ""

echo "[3] Print focused snippets from strongest active candidates"

python3 - << 'PY'

from pathlib import Path

candidates = [

    "worker.js",

    "worker.mjs",

    "server.js",

    "server.mjs",

    "routes/api/delegate.ts",

    "routes/api/tasks.ts",

    "routes/tasks.ts",

    "scripts/_local/agent-runtime/worker.js",

    "scripts/_local/agent-runtime/worker.mjs",

    "scripts/_local/agent-runtime/submit-task.ts",

]

terms = [

    "Standard execution prepared for:",

    "standard execution path",

    "communicationResult",

    "outcome_preview",

    "execution_meta",

    "completed_at",

    "UPDATE tasks",

    "INSERT INTO task_events",

]

for candidate in candidates:

    path = Path(candidate)

    if not path.exists():

        continue

    text = path.read_text(errors="ignore")

    lines = text.splitlines()

    hit_lines = []

    for i, line in enumerate(lines, start=1):

        if any(term in line for term in terms):

            hit_lines.append(i)

    if not hit_lines:

        continue

    print(f"\n===== {candidate} =====")

    shown = set()

    for hit in hit_lines[:12]:

        start = max(1, hit - 5)

        end = min(len(lines), hit + 8)

        key = (start, end)

        if key in shown:

            continue

        shown.add(key)

        print(f"\n--- lines {start}-{end} ---")

        for n in range(start, end + 1):

            print(f"{n}: {lines[n-1]}")

PY

echo ""

echo "===== ACTIVE WORKER WRITER INSPECTION COMPLETE ====="

