
#!/usr/bin/env bash

set -u

echo "===== PHASE 719 INSPECT WORKER COMPLETION CORE ====="

echo ""

echo "[1] Repo/runtime checkpoint"

pwd

git status --short

git log --oneline --decorate -6

docker compose ps

echo ""

echo "[2] Focused worker completion files"

python3 - << 'PY'

from pathlib import Path

files = [

    "server/worker/task_execution_interpreter.mjs",

    "server/worker/execute_task_with_contract.mjs",

    "server/worker/response_compiler.mjs",

    "server/worker/phase26_task_worker.mjs",

    "server/routes/api-tasks-postgres.mjs",

    "server/execution_guidance_runner.mjs",

    "server/execution_guidance_router.mjs",

]

for file in files:

    path = Path(file)

    if not path.exists():

        print(f"\n===== MISSING: {file} =====")

        continue

    lines = path.read_text(errors="ignore").splitlines()

    print(f"\n===== FILE: {file} ({len(lines)} lines) =====")

    for i, line in enumerate(lines, start=1):

        if any(term in line for term in [

            "Standard execution prepared for:",

            "standard execution path",

            "communicationResult",

            "outcome_preview",

            "execution_meta",

            "systemTrace",

            "compile",

            "completed_at",

            "UPDATE tasks",

            "INSERT INTO task_events",

            "payload",

            "completed"

        ]):

            start = max(1, i - 6)

            end = min(len(lines), i + 10)

            print(f"\n--- lines {start}-{end} ---")

            for n in range(start, end + 1):

                print(f"{n}: {lines[n-1]}")

PY

echo ""

echo "[3] Inspect package scripts and compose worker command"

python3 - << 'PY'

from pathlib import Path

for file in ["package.json", "docker-compose.yml", "Dockerfile.worker"]:

    path = Path(file)

    if not path.exists():

        continue

    print(f"\n===== {file} =====")

    print(path.read_text(errors="ignore")[:4000])

PY

echo ""

echo "===== PHASE 719 WORKER COMPLETION CORE INSPECTION COMPLETE ====="

