
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: PATCH RECENT TASKS ARTIFACT METADATA ====="

mkdir -p checkpoints

TARGET="public/js/phase530_visible_panels_bridge.js"

cp "$TARGET" "checkpoints/PHASE719_phase530_visible_panels_bridge_PRE_ARTIFACT_METADATA.js"

python3 - << 'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

needle = '      const explanation = esc(t.explanation_preview || "");\n'

insert = '''      const artifact = t.artifact || (Array.isArray(t.artifacts) ? t.artifacts[0] : null) || null;

      const artifactName = artifact ? esc(artifact.filename || artifact.path || "artifact") : "";

      const artifactType = artifact ? esc(artifact.type || "artifact") : "";

      const artifactSize = artifact && artifact.size_bytes ? esc(String(artifact.size_bytes) + " bytes") : "";

'''

if insert.strip() not in text:

    if needle not in text:

        raise SystemExit("Could not locate explanation preview line; refusing patch.")

    text = text.replace(needle, needle + insert, 1)

needle2 = '''        ${explanation ? `<div class="phase717-muted">Explanation: ${explanation}</div>` : ""}

'''

insert2 = '''        ${artifact ? `<div class="phase717-muted">Artifact: ${artifactName}${artifactType ? ` · ${artifactType}` : ""}${artifactSize ? ` · ${artifactSize}` : ""}</div>` : ""}

'''

if insert2.strip() not in text:

    if needle2 not in text:

        raise SystemExit("Could not locate explanation render line; refusing patch.")

    text = text.replace(needle2, needle2 + insert2, 1)

path.write_text(text)

PY

node --check "$TARGET"

cp "$TARGET" "checkpoints/PHASE719_phase530_visible_panels_bridge_POST_ARTIFACT_METADATA.js"

docker compose up -d --build dashboard

sleep 5

{

  echo "TASK API HEALTH"

  curl -i -s --max-time 10 http://localhost:3000/api/tasks/health || true

  echo ""

  echo "TASK API LIST HAS ARTIFACT"

  curl -s --max-time 10 http://localhost:3000/api/tasks | grep -o '"artifact"' | head || true

  echo ""

  echo "ROOT ROUTE"

  curl -i -s --max-time 10 http://localhost:3000/ | head -n 40 || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 120 motherboard_systems_hq-dashboard-1 || true

} | tee checkpoints/PHASE719_RECENT_TASKS_ARTIFACT_METADATA_VERIFY.txt

git add "$TARGET" \

  PHASE719_PATCH_RECENT_TASKS_ARTIFACT_METADATA.sh \

  checkpoints/PHASE719_phase530_visible_panels_bridge_PRE_ARTIFACT_METADATA.js \

  checkpoints/PHASE719_phase530_visible_panels_bridge_POST_ARTIFACT_METADATA.js \

  checkpoints/PHASE719_RECENT_TASKS_ARTIFACT_METADATA_VERIFY.txt

git commit -m "Phase 719: surface artifact metadata in recent tasks"

git push origin "$(git branch --show-current)"

echo "===== ARTIFACT METADATA PATCH COMPLETE ====="

