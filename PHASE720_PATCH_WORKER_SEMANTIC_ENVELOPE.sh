
#!/usr/bin/env bash

set -euo pipefail

TARGET="server/worker/phase26_task_worker.mjs"

BACKUP="checkpoints/PHASE720_PRE_SEMANTIC_ENVELOPE_WORKER.mjs"

echo "===== PHASE 720 WORKER SEMANTIC ENVELOPE PATCH ====="

cp "$TARGET" "$BACKUP"

python3 << 'PY'

from pathlib import Path

path = Path("server/worker/phase26_task_worker.mjs")

text = path.read_text()

old = '''      const content = [

'''

new = '''      const semanticEnvelope = [

        "<!-- MB_SEMANTIC_ARTIFACT_V1",

        JSON.stringify({

          artifact_kind: "task_execution_summary",

          semantic_version: "1.0",

          task_summary: artifactSummary,

          execution_plan: artifactRecommendations,

          actionable_outputs: [artifactDeliverable],

          evidence_notes: artifactDetails

            .split("\\n")

            .map((line) => line.trim())

            .filter(Boolean),

          operator_next_steps: artifactNextSteps,

          raw_markdown_fallback: true

        }, null, 2),

        "-->"

      ].join("\\n");

      const content = [

        semanticEnvelope,

        "",

'''

if old not in text:

    raise SystemExit("TARGET BLOCK NOT FOUND")

updated = text.replace(old, new, 1)

path.write_text(updated)

print("Semantic envelope patch applied.")

PY

echo ""

echo "[1] Verify semantic envelope insertion"

grep -n "MB_SEMANTIC_ARTIFACT_V1" "$TARGET"

echo ""

echo "[2] Docker rebuild"

docker compose build dashboard worker

echo ""

echo "[3] Restart containers"

docker compose up -d dashboard worker

echo ""

echo "[4] Runtime status"

docker ps

echo ""

echo "===== PATCH COMPLETE ====="

