
#!/usr/bin/env bash

set -u

echo "===== PHASE 719 SAFE ARTIFACT EXISTENCE VERIFICATION ====="

echo ""

echo "[1] Repo + runtime status"

pwd

git status --short

git log --oneline --decorate -5

docker compose ps

echo ""

echo "[2] Latest task payload shape"

curl -s http://localhost:3000/api/tasks > /tmp/phase719-api-tasks.json

python3 - << 'PY'

import json

from pathlib import Path

p = Path("/tmp/phase719-api-tasks.json")

data = json.loads(p.read_text())

tasks = data.get("tasks", [])

print("ok:", data.get("ok"))

print("task_count:", len(tasks))

if tasks:

    task = tasks[0]

    print("latest_task_keys:", sorted(task.keys()))

    for key in ["task_id", "status", "title", "outcome_preview", "explanation_preview", "guidance", "result", "output", "artifact", "artifacts", "execution_meta"]:

        if key in task:

            value = task[key]

            print(f"\n--- {key} ---")

            if isinstance(value, (dict, list)):

                print(json.dumps(value, indent=2)[:1500])

            else:

                print(str(value)[:1500])

PY

echo ""

echo "[3] Recent task_events payload sample"

docker compose exec -T postgres psql -U postgres -d motherboard -c "

SELECT

  event_type,

  left(coalesce(payload::text,''), 800) AS payload_preview,

  created_at

FROM task_events

ORDER BY created_at DESC

LIMIT 8;

"

echo ""

echo "[4] Python artifact/code search, excluding noisy directories"

python3 - << 'PY'

from pathlib import Path

root = Path(".")

skip_dirs = {".git", "node_modules", "dist", "build", ".next"}

artifact_name_terms = ("artifact", "output", "result", "generated", "export", "execution", "render", "task")

artifact_suffixes = {".html", ".md", ".json", ".txt", ".pdf"}

write_terms = (

    "writeFile",

    "fs.writeFile",

    "createWriteStream",

    "output_path",

    "artifact_path",

    "generated_file",

    "download_url",

    "persistArtifact",

    "saveArtifact",

    "save artifact",

    "persist artifact",

)

artifact_files = []

write_refs = []

for path in root.rglob("*"):

    if any(part in skip_dirs for part in path.parts):

        continue

    if path.is_file():

        lower_name = str(path).lower()

        if path.suffix.lower() in artifact_suffixes and any(term in lower_name for term in artifact_name_terms):

            artifact_files.append(str(path))

        if path.suffix.lower() in {".ts", ".js", ".mjs", ".cjs", ".tsx", ".jsx", ".json", ".md", ".txt", ".sh"}:

            try:

                text = path.read_text(errors="ignore")

            except Exception:

                continue

            for term in write_terms:

                if term in text:

                    write_refs.append((str(path), term))

                    break

print("POSSIBLE_ARTIFACT_FILES:")

for item in artifact_files[:80]:

    print("-", item)

print("\nWRITE_OPERATION_REFERENCES:")

for path, term in write_refs[:80]:

    print(f"- {path} :: {term}")

print("\nCOUNTS:")

print("possible_artifact_files:", len(artifact_files))

print("write_operation_reference_files:", len(write_refs))

PY

echo ""

echo "===== SAFE ARTIFACT EXISTENCE VERIFICATION COMPLETE ====="

