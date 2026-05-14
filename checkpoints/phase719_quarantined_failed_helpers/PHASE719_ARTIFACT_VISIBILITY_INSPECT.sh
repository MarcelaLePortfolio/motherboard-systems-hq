
#!/usr/bin/env bash

set -u

echo "===== PHASE 719 ARTIFACT VISIBILITY INSPECTION ====="

echo ""

echo "[0] Confirm repo/runtime context"

pwd

git status --short

git log --oneline --decorate -5

echo ""

echo "[1] Docker runtime"

docker compose ps

echo ""

echo "[2] Search artifact/result/output persistence references"

grep -RniE "artifact|artifacts|result|results|output|outputs|outcome|execution_meta|task_events|completion|completed" . \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  --exclude-dir=dist \

  --exclude-dir=build \

  --exclude="*.log" \

  --exclude="*.tar.gz" \

  | head -300 || true

echo ""

echo "[3] Locate worker/task/execution/delegate files"

find . -type f \

  \( -iname '*worker*' -o -iname '*task*' -o -iname '*execution*' -o -iname '*delegate*' -o -iname '*event*' \) \

  -not -path '*/node_modules/*' \

  -not -path '*/.git/*' \

  -not -path '*/dist/*' \

  -not -path '*/build/*' \

  | sort

echo ""

echo "[4] Locate dashboard/recent/lifecycle renderer files"

find . -type f \

  \( -iname '*dashboard*' -o -iname '*recent*' -o -iname '*lifecycle*' -o -iname '*panel*' -o -iname '*bridge*' \) \

  -not -path '*/node_modules/*' \

  -not -path '*/.git/*' \

  -not -path '*/dist/*' \

  -not -path '*/build/*' \

  | sort

echo ""

echo "[5] Inspect current task payload shape"

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

    print("top_level_keys:", sorted(t.keys()))

    for key in [

        "id",

        "task_id",

        "title",

        "status",

        "outcome_preview",

        "explanation_preview",

        "guidance",

        "result",

        "output",

        "artifact",

        "artifacts",

        "execution_meta"

    ]:

        if key in t:

            v = t[key]

            print(f"\n--- {key} ---")

            if isinstance(v, (dict, list)):

                print(json.dumps(v, indent=2)[:2500])

            else:

                print(str(v)[:2500])

PY

echo ""

echo "[6] Inspect database tables/columns relevant to artifacts"

docker compose exec -T postgres psql -U postgres -d motherboard << 'SQL'

\dt

SELECT table_name, column_name, data_type

FROM information_schema.columns

WHERE table_schema='public'

ORDER BY table_name, ordinal_position;

SQL

echo ""

echo "[7] Inspect recent task rows and event rows"

docker compose exec -T postgres psql -U postgres -d motherboard << 'SQL'

SELECT

  id,

  task_id,

  title,

  status,

  left(coalesce(outcome_preview,''), 240) AS outcome_preview,

  left(coalesce(explanation_preview,''), 240) AS explanation_preview,

  updated_at

FROM tasks

ORDER BY updated_at DESC

LIMIT 10;

SELECT

  id,

  task_id,

  event_type,

  left(coalesce(payload::text,''), 500) AS payload_preview,

  created_at

FROM task_events

ORDER BY created_at DESC

LIMIT 20;

SQL

echo ""

echo "[8] Save inspection note"

cat > PHASE719_ARTIFACT_VISIBILITY_INSPECTION.md << 'NOTE'

# Phase 719 Artifact Visibility Inspection

## Purpose

Inspect current runtime, worker completion payloads, task API shape, database schema, and renderer files before implementing artifact/result visibility.

## Confirmed before inspection

- Docker runtime remains active.

- `/api/tasks` returns completed task data.

- External archive backup completed at commit `ca32876f`.

## Inspection target

Determine whether execution outputs already exist in:

- `tasks`

- `task_events`

- guidance payloads

- worker completion payloads

- filesystem artifact locations

- renderer-visible Recent Tasks state

## Implementation boundary

Next patch must be minimal and read-only:

- surface existing real result data only

- do not fabricate artifacts

- do not alter retry semantics

- do not alter worker execution semantics

- do not broaden CSS scope

NOTE

git add PHASE719_ARTIFACT_VISIBILITY_INSPECT.sh PHASE719_ARTIFACT_VISIBILITY_INSPECTION.md

git commit -m "Phase 719: add artifact visibility inspection script"

git push origin dev

echo ""

echo "===== PHASE 719 ARTIFACT VISIBILITY INSPECTION COMPLETE ====="

