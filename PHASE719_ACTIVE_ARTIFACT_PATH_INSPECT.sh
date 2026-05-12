
#!/usr/bin/env bash

set -u

echo "===== PHASE 719 ACTIVE ARTIFACT PATH INSPECTION ====="

echo ""

echo "[1] Runtime + repo"

pwd

git status --short

git log --oneline --decorate -6

docker compose ps

echo ""

echo "[2] Discover Postgres databases"

docker compose exec -T postgres psql -U postgres -c "SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname;"

echo ""

echo "[3] Inspect likely active task/worker/API files"

python3 - << 'PY'

from pathlib import Path

targets = [

    "server.js",

    "server.mjs",

    "worker.js",

    "worker.mjs",

    "tasks.ts",

    "routes/api/tasks.ts",

    "routes/tasks.ts",

    "scripts/_local/agent-runtime/utils/cade_task_processor.ts",

    "scripts/_local/agent-runtime/utils/cade_task_processor_clean.ts",

    "cade_task_processor.ts",

    "handleTask.ts",

    "runSkill.ts",

    "scripts/_local/agent-runtime/tools/generateMarkdownFile.mjs",

    "scripts/_safety/artifact_safe_io.sh",

]

terms = [

    "outcome_preview",

    "communicationResult",

    "execution_meta",

    "writeFile",

    "artifact",

    "output",

    "result",

    "task_events",

    "INSERT INTO tasks",

    "UPDATE tasks",

    "completed",

]

for target in targets:

    path = Path(target)

    if not path.exists():

        continue

    print(f"\n===== FILE: {target} =====")

    text = path.read_text(errors="ignore")

    lines = text.splitlines()

    hits = []

    for i, line in enumerate(lines, start=1):

        if any(term in line for term in terms):

            hits.append(i)

    windows = []

    for hit in hits[:20]:

        start = max(1, hit - 3)

        end = min(len(lines), hit + 5)

        windows.append((start, end))

    merged = []

    for start, end in windows:

        if merged and start <= merged[-1][1] + 1:

            merged[-1] = (merged[-1][0], max(merged[-1][1], end))

        else:

            merged.append((start, end))

    if not merged:

        print("No targeted terms found.")

        continue

    for start, end in merged[:8]:

        print(f"\n--- lines {start}-{end} ---")

        for n in range(start, end + 1):

            print(f"{n}: {lines[n-1]}")

PY

echo ""

echo "[4] Inspect task payload full communicationResult/execution_meta only"

curl -s http://localhost:3000/api/tasks > /tmp/phase719-api-tasks.json

python3 - << 'PY'

import json

from pathlib import Path

data = json.loads(Path("/tmp/phase719-api-tasks.json").read_text())

tasks = data.get("tasks", [])

if not tasks:

    print("No tasks returned.")

    raise SystemExit

task = tasks[0]

guidance = task.get("guidance") or {}

comm = guidance.get("communicationResult") or {}

trace = comm.get("systemTrace") or {}

meta = trace.get("content", {}).get("execution_meta") if isinstance(trace.get("content"), dict) else None

print("task_id:", task.get("task_id"))

print("status:", task.get("status"))

print("top_level_has_artifact:", any(k in task for k in ["artifact", "artifacts", "result", "output", "execution_meta"]))

print("communicationResult_keys:", sorted(comm.keys()))

print("systemTrace_content_keys:", sorted((trace.get("content") or {}).keys()) if isinstance(trace.get("content"), dict) else [])

print("execution_meta:")

print(json.dumps(meta, indent=2)[:2500] if meta is not None else "None")

PY

echo ""

echo "===== ACTIVE ARTIFACT PATH INSPECTION COMPLETE ====="

