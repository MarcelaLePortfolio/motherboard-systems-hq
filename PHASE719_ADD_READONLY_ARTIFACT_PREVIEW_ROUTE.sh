
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: ADD READONLY ARTIFACT PREVIEW ROUTE ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

TARGET="server/routes/api-tasks-postgres.mjs"

cp "$TARGET" checkpoints/PHASE719_API_TASKS_POSTGRES_PRE_ARTIFACT_PREVIEW_ROUTE.mjs

python3 - << 'PY'

from pathlib import Path

path = Path("server/routes/api-tasks-postgres.mjs")

text = path.read_text()

if 'import fs from "fs";' not in text:

    text = text.replace('import crypto from "crypto";\n', 'import crypto from "crypto";\nimport fs from "fs";\nimport path from "path";\n', 1)

if 'GET /api/tasks/:task_id/artifact-preview' in text:

    raise SystemExit("Artifact preview route already present.")

marker = '// POST /api/tasks/create  { task_id?, title?, agent?, run_id?, ... }\n'

route = r'''

// GET /api/tasks/:task_id/artifact-preview

router.get("/:task_id/artifact-preview", async (req, res) => {

  try {

    const taskId = String(req.params.task_id || "").trim();

    if (!taskId) {

      return res.status(400).json({ ok: false, error: "task_id_required" });

    }

    const q = await pool.query(

      `

      SELECT

        completed.payload->'artifact' AS artifact,

        completed.payload->'artifacts' AS artifacts

      FROM tasks t

      LEFT JOIN LATERAL (

        SELECT te.payload

        FROM task_events te

        WHERE te.task_id = t.task_id

          AND te.kind = 'task.completed'

        ORDER BY te.ts DESC

        LIMIT 1

      ) completed ON true

      WHERE t.task_id = $1

      LIMIT 1

      `,

      [taskId]

    );

    const row = q.rows?.[0] || null;

    if (!row) {

      return res.status(404).json({ ok: false, error: "task_not_found" });

    }

    const artifact =

      row.artifact ||

      (Array.isArray(row.artifacts) ? row.artifacts[0] : null);

    if (!artifact || !artifact.path) {

      return res.status(404).json({ ok: false, error: "artifact_not_found" });

    }

    const artifactDir = process.env.MB_ARTIFACT_DIR || "/app/data/artifacts";

    const resolvedPath = path.resolve(String(artifact.path));

    const resolvedDir = path.resolve(artifactDir);

    if (!resolvedPath.startsWith(resolvedDir)) {

      return res.status(403).json({ ok: false, error: "artifact_path_rejected" });

    }

    if (!fs.existsSync(resolvedPath)) {

      return res.status(404).json({ ok: false, error: "artifact_file_missing" });

    }

    const content = fs.readFileSync(resolvedPath, "utf8");

    return res.status(200).json({

      ok: true,

      task_id: taskId,

      artifact: {

        filename: artifact.filename || null,

        type: artifact.type || null,

        size_bytes: artifact.size_bytes || null,

        created_at: artifact.created_at || null

      },

      content

    });

  } catch (e) {

    console.error("[phase719] artifact preview route error", e);

    return res.status(500).json({ ok: false, error: "artifact_preview_failed" });

  }

});

'''

if marker not in text:

    raise SystemExit("Could not locate insertion marker.")

text = text.replace(marker, route + "\n" + marker, 1)

path.write_text(text)

PY

node --check "$TARGET"

cp "$TARGET" checkpoints/PHASE719_API_TASKS_POSTGRES_POST_ARTIFACT_PREVIEW_ROUTE.mjs

docker compose up -d --build dashboard

sleep 5

TASK_ID="$(curl -s --max-time 10 http://localhost:3000/api/tasks | python3 - << 'PY'

import json, sys

try:

    data = json.load(sys.stdin)

    for task in data.get("tasks", []):

        artifact = task.get("artifact") or (task.get("artifacts") or [None])[0]

        if artifact:

            print(task.get("task_id", ""))

            break

except Exception:

    pass

PY

)"

{

  echo "RUNTIME HEALTH"

  curl -i -s --max-time 10 http://localhost:3000/api/tasks/health || true

  echo ""

  echo "TASK ID"

  echo "$TASK_ID"

  echo ""

  echo "ARTIFACT PREVIEW ROUTE TEST"

  if [ -n "$TASK_ID" ]; then

    curl -i -s --max-time 10 "http://localhost:3000/api/tasks/$TASK_ID/artifact-preview" | head -n 80 || true

  else

    echo "No artifact task found for preview test."

  fi

  echo ""

  echo "ROUTE MARKERS"

  grep -nE "artifact-preview|artifact_path_rejected|artifact_preview_failed" "$TARGET" || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 120 motherboard_systems_hq-dashboard-1 || true

} | tee checkpoints/PHASE719_ARTIFACT_PREVIEW_ROUTE_VERIFY.txt

git add "$TARGET"

git add PHASE719_ADD_READONLY_ARTIFACT_PREVIEW_ROUTE.sh

git add checkpoints/PHASE719_API_TASKS_POSTGRES_PRE_ARTIFACT_PREVIEW_ROUTE.mjs

git add checkpoints/PHASE719_API_TASKS_POSTGRES_POST_ARTIFACT_PREVIEW_ROUTE.mjs

git add checkpoints/PHASE719_ARTIFACT_PREVIEW_ROUTE_VERIFY.txt

git commit -m "Phase 719: add readonly artifact preview route"

git push origin "$BRANCH"

echo "===== READONLY ARTIFACT PREVIEW ROUTE COMPLETE ====="

