
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 ADD REAL ARTIFACT PERSISTENCE ====="

echo ""

echo "[1] Patch active worker with minimal artifact persistence"

python3 - << 'PY'

from pathlib import Path

path = Path("server/worker/phase26_task_worker.mjs")

text = path.read_text()

if "PHASE 719 — REAL ARTIFACT PERSISTENCE" in text:

    print("Artifact persistence patch already present.")

    raise SystemExit

if 'import fs from "node:fs";' not in text:

    text = text.replace(

        'import { Pool } from "pg";',

        'import { Pool } from "pg";\nimport fs from "node:fs";\nimport path from "node:path";'

    )

helper = '''

function safeArtifactName(value = "") {

  return String(value)

    .replace(/[^a-zA-Z0-9._-]/g, "_")

    .replace(/_+/g, "_")

    .slice(0, 120);

}

function persistTaskArtifact({ task, completed, executionResult }) {

  const taskId = completed?.task_id ?? task?.task_id ?? `task_${Date.now()}`;

  const runId = completed?.run_id ?? task?.run_id ?? "run_unknown";

  const artifactDir = process.env.MB_ARTIFACT_DIR || "/app/data/artifacts";

  fs.mkdirSync(artifactDir, { recursive: true });

  const filename = `${safeArtifactName(taskId)}_${safeArtifactName(runId)}.md`;

  const artifactPath = path.join(artifactDir, filename);

  const outcome = executionResult?.communicationResult?.outcome?.content ?? "";

  const explanation = executionResult?.communicationResult?.explanation?.content ?? "";

  const systemTrace = executionResult?.communicationResult?.systemTrace?.content ?? {};

  const content = [

    `# Task Artifact`,

    ``,

    `## Task`,

    String(task?.title ?? task?.payload?.title ?? taskId),

    ``,

    `## Status`,

    String(completed?.status ?? "completed"),

    ``,

    `## Outcome`,

    outcome || "No outcome content was produced.",

    ``,

    `## Explanation`,

    explanation || "No explanation content was produced.",

    ``,

    `## Execution Trace`,

    "```json",

    JSON.stringify(systemTrace, null, 2),

    "```",

    ``,

  ].join("\\n");

  fs.writeFileSync(artifactPath, content, "utf8");

  return {

    type: "markdown",

    filename,

    path: artifactPath,

    size_bytes: Buffer.byteLength(content, "utf8"),

    created_at: new Date().toISOString(),

    source: "worker",

  };

}

'''

insert_anchor = "async function processOne(pool) {"

text = text.replace(insert_anchor, helper + "\n" + insert_anchor)

old = '''    await emitTaskEvent({

      pool,

      kind: "task.completed",

      task_id: completed.task_id,

      run_id: completed.run_id ?? task.run_id ?? null,

      actor: OWNER,

      payload: {

        status: completed.status,

        source: "worker",

        claimed_by: completed.claimed_by,

        completed_at: completed.completed_at,

        communicationResult: executionResult?.communicationResult ?? null,

        outcome_preview: executionResult?.communicationResult?.outcome?.content ?? null,

        explanation_preview: executionResult?.communicationResult?.explanation?.content ?? null

      }

    });'''

new = '''    // PHASE 719 — REAL ARTIFACT PERSISTENCE

    // Persist a real, inspectable markdown artifact for every completed worker task.

    const artifact = persistTaskArtifact({ task, completed, executionResult });

    await emitTaskEvent({

      pool,

      kind: "task.completed",

      task_id: completed.task_id,

      run_id: completed.run_id ?? task.run_id ?? null,

      actor: OWNER,

      payload: {

        status: completed.status,

        source: "worker",

        claimed_by: completed.claimed_by,

        completed_at: completed.completed_at,

        communicationResult: executionResult?.communicationResult ?? null,

        outcome_preview: executionResult?.communicationResult?.outcome?.content ?? null,

        explanation_preview: executionResult?.communicationResult?.explanation?.content ?? null,

        artifact,

        artifacts: [artifact]

      }

    });'''

if old not in text:

    raise SystemExit("Could not find expected emitTaskEvent block. No patch applied.")

text = text.replace(old, new)

path.write_text(text)

print("Patched server/worker/phase26_task_worker.mjs")

PY

echo ""

echo "[2] Patch /api/tasks to expose artifact metadata from completed event payload"

python3 - << 'PY'

from pathlib import Path

path = Path("server/routes/api-tasks-postgres.mjs")

text = path.read_text()

if "completed.payload->'artifact' AS artifact" in text:

    print("/api/tasks artifact exposure already present.")

    raise SystemExit

old = '''        completed.payload->>'outcome_preview' AS outcome_preview,

        completed.payload->>'explanation_preview' AS explanation_preview,

        completed.payload AS guidance'''

new = '''        completed.payload->>'outcome_preview' AS outcome_preview,

        completed.payload->>'explanation_preview' AS explanation_preview,

        completed.payload->'artifact' AS artifact,

        completed.payload->'artifacts' AS artifacts,

        completed.payload AS guidance'''

if old not in text:

    raise SystemExit("Could not find expected /api/tasks select block. No patch applied.")

text = text.replace(old, new)

path.write_text(text)

print("Patched server/routes/api-tasks-postgres.mjs")

PY

echo ""

echo "[3] Rebuild worker/dashboard containers"

docker compose build worker dashboard

docker compose up -d

echo ""

echo "[4] Delegate fresh artifact verification task"

curl -s -X POST http://localhost:3000/api/delegate-task \

  -H "Content-Type: application/json" \

  -d '{"title":"Create a short artifact proof for Moonrise Bakery showing a headline, tagline, and three section ideas.","task":"Create a short artifact proof for Moonrise Bakery showing a headline, tagline, and three section ideas."}' \

  | python3 -m json.tool || true

echo ""

echo "[5] Give worker time to claim/complete"

sleep 8

echo ""

echo "[6] Verify /api/tasks exposes artifact metadata"

curl -s http://localhost:3000/api/tasks > /tmp/phase719-artifact-api-tasks.json

python3 - << 'PY'

import json

from pathlib import Path

data = json.loads(Path("/tmp/phase719-artifact-api-tasks.json").read_text())

tasks = data.get("tasks", [])

print("ok:", data.get("ok"))

print("task_count:", len(tasks))

if not tasks:

    raise SystemExit("No tasks returned.")

task = tasks[0]

print("task_id:", task.get("task_id"))

print("status:", task.get("status"))

print("artifact:", json.dumps(task.get("artifact"), indent=2))

print("artifacts:", json.dumps(task.get("artifacts"), indent=2))

artifact = task.get("artifact") or {}

artifact_path = artifact.get("path")

if artifact_path:

    p = Path(artifact_path)

    print("artifact_path_exists:", p.exists())

    print("artifact_size:", p.stat().st_size if p.exists() else None)

    if p.exists():

        print("artifact_preview:")

        print(p.read_text(errors="ignore")[:1200])

PY

echo ""

echo "[7] Git status"

git status --short

echo ""

echo "===== PHASE 719 REAL ARTIFACT PERSISTENCE PATCH COMPLETE ====="

