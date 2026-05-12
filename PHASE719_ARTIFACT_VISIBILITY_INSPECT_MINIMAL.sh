
#!/usr/bin/env bash

set -u

echo "===== PHASE 719 MINIMAL ARTIFACT INSPECTION — FIXED ====="

echo ""

echo "[1] Repo status"

pwd

git status --short

git log --oneline --decorate -3

echo ""

echo "[2] Docker runtime"

docker compose ps

echo ""

echo "[3] Current task payload keys"

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

    t = tasks[0]

    print("\nTOP LEVEL KEYS:")

    for k in sorted(t.keys()):

        print("-", k)

    print("\nPREVIEW FIELDS:")

    for key in ["status", "title", "outcome_preview", "explanation_preview"]:

        if key in t:

            print(f"\n{key}:")

            print(str(t[key])[:500])

PY

echo ""

echo "[4] Relevant DB tables"

docker compose exec -T postgres psql -U postgres -d motherboard -c "

SELECT table_name

FROM information_schema.tables

WHERE table_schema='public'

ORDER BY table_name;

"

echo ""

echo "[5] Recent task_events sample"

docker compose exec -T postgres psql -U postgres -d motherboard -c "

SELECT

  event_type,

  left(coalesce(payload::text,''), 300) AS payload_preview

FROM task_events

ORDER BY created_at DESC

LIMIT 5;

"

echo ""

echo "[6] Relevant renderer/task files, excluding .git"

find . \

  -path './.git' -prune -o \

  -path './node_modules' -prune -o \

  -type f \

  \( -name '*recent*' -o -name '*task*' -o -name '*lifecycle*' -o -name '*dashboard*' \) \

  -print | head -50

echo ""

echo "===== MINIMAL INSPECTION COMPLETE ====="

