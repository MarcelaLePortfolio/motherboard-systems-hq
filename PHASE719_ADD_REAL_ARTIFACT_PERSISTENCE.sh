
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 ADD REAL ARTIFACT PERSISTENCE — SAFE PATCH ====="

python3 - << 'PY'

from pathlib import Path

worker = Path("server/worker/phase26_task_worker.mjs")

text = worker.read_text()

if 'import fs from "node:fs";' not in text:

    text = text.replace('import { Pool } from "pg";', 'import { Pool } from "pg";\nimport fs from "node:fs";\nimport path from "node:path";')

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

    "# Task Artifact",

    "",

    "## Task",

    String(task?.title ?? task?.payload?.title ?? taskId),

    "",

    "## Status",

    String(completed?.status ?? "completed"),

    "",

    "## Outcome",

    outcome || "No outcome content was produced.",

    "",

    "## Explanation",

    explanation || "No explanation content was produced.",

    "",

    "## Execution Trace",

    "```json",

    JSON.stringify(systemTrace, null, 2),

    "```",

    ""

  ].join("\\n");

  fs.writeFileSync(artifactPath, content, "utf8");

  return {

    type: "markdown",

    filename,

    path: artifactPath,

    size_bytes: Buffer.byteLength(content, "utf8"),

    created_at: new Date().toISOString(),

    source: "worker"

  };

}

'''

if "function persistTaskArtifact" not in text:

    text = text.replace("async function processOne(pool) {", helper + "\nasync function processOne(pool) {")

if "const artifact = persistTaskArtifact({ task, completed, executionResult });" not in text:

    marker = "    await emitTaskEvent({\n      pool,\n      kind: \"task.completed\","

    if marker not in text:

        raise SystemExit("Could not locate task.completed emitTaskEvent marker.")

    text = text.replace(

        marker,

        "    const artifact = persistTaskArtifact({ task, completed, executionResult });\n\n" + marker,

        1

    )

if "        artifact," not in text:

    target = "        explanation_preview: executionResult?.communicationResult?.explanation?.content ?? null"

    if target not in text:

        raise SystemExit("Could not locate explanation_preview line.")

    text = text.replace(

        target,

        target + ",\n        artifact,\n        artifacts: [artifact]",

        1

    )

worker.write_text(text)

print("patched worker artifact persistence")

PY

python3 - << 'PY'

from pathlib import Path

api = Path("server/routes/api-tasks-postgres.mjs")

text = api.read_text()

if "completed.payload->'artifact' AS artifact" not in text:

    target = "        completed.payload->>'explanation_preview' AS explanation_preview,\n        completed.payload AS guidance"

    replacement = "        completed.payload->>'explanation_preview' AS explanation_preview,\n        completed.payload->'artifact' AS artifact,\n        completed.payload->'artifacts' AS artifacts,\n        completed.payload AS guidance"

    if target not in text:

        raise SystemExit("Could not locate /api/tasks guidance select block.")

    text = text.replace(target, replacement, 1)

api.write_text(text)

print("patched /api/tasks artifact exposure")

PY

echo ""

echo "[1] Rebuild and restart"

docker compose build worker dashboard

docker compose up -d

echo ""

echo "[2] Create fresh delegated task"

curl -s -X POST http://localhost:3000/api/delegate-task \

  -H "Content-Type: application/json" \

  -d '{"title":"Create a real artifact proof for Moonrise Bakery with headline, tagline, and three section ideas.","task":"Create a real artifact proof for Moonrise Bakery with headline, tagline, and three section ideas."}' \

  | python3 -m json.tool || true

sleep 10

echo ""

echo "[3] Verify artifact metadata"

curl -s http://localhost:3000/api/tasks > /tmp/phase719-real-artifact-tasks.json

python3 - << 'PY'

import json

from pathlib import Path

data = json.loads(Path("/tmp/phase719-real-artifact-tasks.json").read_text())

tasks = data.get("tasks", [])

print("ok:", data.get("ok"))

print("task_count:", len(tasks))

if not tasks:

    raise SystemExit("No tasks returned.")

task = tasks[0]

artifact = task.get("artifact")

print("task_id:", task.get("task_id"))

print("status:", task.get("status"))

print("artifact:", json.dumps(artifact, indent=2))

if not artifact:

    raise SystemExit("Artifact metadata missing from latest task.")

artifact_path = artifact.get("path")

if not artifact_path:

    raise SystemExit("Artifact path missing.")

p = Path(artifact_path)

print("artifact_path_exists:", p.exists())

if not p.exists():

    raise SystemExit("Artifact file does not exist at recorded path.")

print("artifact_size:", p.stat().st_size)

print("artifact_preview:")

print(p.read_text(errors="ignore")[:1200])

PY

echo ""

echo "===== PHASE 719 REAL ARTIFACT PERSISTENCE VERIFIED ====="

