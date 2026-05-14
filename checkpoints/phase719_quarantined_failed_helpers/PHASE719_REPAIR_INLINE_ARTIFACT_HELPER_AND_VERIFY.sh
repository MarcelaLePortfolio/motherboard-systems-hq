
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 REPAIR INLINE ARTIFACT HELPER AND VERIFY ====="

echo ""

echo "[1] Patch worker with inline helper before existing artifact call"

python3 - << 'PY'

from pathlib import Path

p = Path("server/worker/phase26_task_worker.mjs")

text = p.read_text()

if 'import fs from "node:fs";' not in text:

    lines = text.splitlines()

    insert_at = 0

    for i, line in enumerate(lines):

        if line.startswith("import "):

            insert_at = i + 1

    lines.insert(insert_at, 'import fs from "node:fs";')

    lines.insert(insert_at + 1, 'import path from "node:path";')

    text = "\n".join(lines) + "\n"

inline_helper = '''    function safeArtifactName(value = "") {

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

    marker = "    const artifact = persistTaskArtifact({ task, completed, executionResult });"

    if marker not in text:

        raise SystemExit("Could not locate existing artifact call marker.")

    text = text.replace(marker, inline_helper + marker, 1)

p.write_text(text)

print("inline artifact helper repaired")

PY

echo ""

echo "[2] Confirm local patch"

python3 - << 'PY'

from pathlib import Path

text = Path("server/worker/phase26_task_worker.mjs").read_text()

for needle in [

  'import fs from "node:fs";',

  'import path from "node:path";',

  'function persistTaskArtifact',

  'const artifact = persistTaskArtifact',

  'artifacts: [artifact]'

]:

    print(f"{needle}: {needle in text}")

PY

echo ""

echo "[3] Rebuild and restart"

docker compose build worker dashboard

docker compose up -d

echo ""

echo "[4] Confirm helper exists inside worker container"

docker compose exec -T worker sh -lc 'grep -nE "import fs|import path|function persistTaskArtifact|const artifact = persistTaskArtifact|artifacts" /app/server/worker/phase26_task_worker.mjs | head -120'

echo ""

echo "[5] Delegate fresh verification task"

curl -s -X POST "http://localhost:3000/api/delegate-task" -H "Content-Type: application/json" --data-raw '{"title":"Create a verified real artifact proof for Moonrise Bakery with headline, tagline, and three section ideas.","task":"Create a verified real artifact proof for Moonrise Bakery with headline, tagline, and three section ideas."}' | python3 -m json.tool || true

echo ""

echo "[6] Wait for worker completion"

sleep 15

echo ""

echo "[7] Verify artifact metadata through API and artifact file inside worker container"

curl -s "http://localhost:3000/api/tasks" > /tmp/phase719-inline-helper-api-tasks.json

ARTIFACT_PATH="$(python3 - << 'PY'

import json

from pathlib import Path

data = json.loads(Path("/tmp/phase719-inline-helper-api-tasks.json").read_text())

tasks = data.get("tasks", [])

print("", end="") if tasks else (_ for _ in ()).throw(SystemExit("No tasks returned."))

task = tasks[0]

artifact = task.get("artifact")

print("API_OK", data.get("ok"), file=__import__("sys").stderr)

print("TASK_COUNT", len(tasks), file=__import__("sys").stderr)

print("TASK_ID", task.get("task_id"), file=__import__("sys").stderr)

print("STATUS", task.get("status"), file=__import__("sys").stderr)

print("ARTIFACT", json.dumps(artifact, indent=2), file=__import__("sys").stderr)

if task.get("status") != "completed":

    raise SystemExit("Latest task is not completed.")

if not artifact:

    raise SystemExit("Artifact metadata missing.")

if not artifact.get("path"):

    raise SystemExit("Artifact path missing.")

print(artifact["path"])

PY

)"

echo "artifact_path=$ARTIFACT_PATH"

docker compose exec -T worker sh -lc "test -s '$ARTIFACT_PATH' && wc -c '$ARTIFACT_PATH' && sed -n '1,80p' '$ARTIFACT_PATH'"

echo ""

echo "[8] Commit verified repair"

git status --short

git add server/worker/phase26_task_worker.mjs server/routes/api-tasks-postgres.mjs PHASE719_ADD_REAL_ARTIFACT_PERSISTENCE.sh PHASE719_REPAIR_INLINE_ARTIFACT_HELPER_AND_VERIFY.sh

git commit -m "Phase 719: repair inline artifact persistence helper"

git push origin dev

echo ""

echo "===== PHASE 719 REAL ARTIFACT PERSISTENCE VERIFIED ====="

