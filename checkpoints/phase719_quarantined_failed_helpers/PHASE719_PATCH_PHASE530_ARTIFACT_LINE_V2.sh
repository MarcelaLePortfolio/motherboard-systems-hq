
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: PATCH PHASE530 ARTIFACT LINE V2 ====="

mkdir -p checkpoints

TARGET="public/js/phase530_visible_panels_bridge.js"

cp "$TARGET" checkpoints/PHASE719_PHASE530_PRE_ARTIFACT_LINE_V2.js

python3 - << 'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

needle_vars = '      const explanation = esc(t.explanation_preview || "");\n'

insert_vars = '''      const artifactRaw = t.artifact || (Array.isArray(t.artifacts) ? t.artifacts[0] : null) || null;

      const artifactName = artifactRaw ? esc(artifactRaw.filename || artifactRaw.path || "artifact") : "";

      const artifactType = artifactRaw ? esc(artifactRaw.type || "artifact") : "";

      const artifactSize = artifactRaw && artifactRaw.size_bytes ? esc(String(artifactRaw.size_bytes) + " bytes") : "";

'''

if "const artifactRaw =" not in text:

    if needle_vars not in text:

        raise SystemExit("Variable insertion point not found.")

    text = text.replace(needle_vars, needle_vars + insert_vars, 1)

needle_render = '''            </div>

              ${""}

            ${""}

'''

insert_render = '''            </div>

            ${artifactRaw ? `<div style="margin-top:8px;color:#86efac;font-size:11px;line-height:1.5;overflow-wrap:anywhere;border:1px solid rgba(134,239,172,.28);border-radius:10px;padding:7px;background:rgba(20,83,45,.14);">Artifact: ${artifactName}${artifactType ? ` · ${artifactType}` : ""}${artifactSize ? ` · ${artifactSize}` : ""}</div>` : ""}

              ${""}

            ${""}

'''

if "Artifact: ${artifactName}" not in text:

    if needle_render not in text:

        raise SystemExit("Render insertion point not found.")

    text = text.replace(needle_render, insert_render, 1)

path.write_text(text)

PY

node --check "$TARGET"

cp "$TARGET" checkpoints/PHASE719_PHASE530_POST_ARTIFACT_LINE_V2.js

docker compose up -d --build dashboard

sleep 5

{

  echo "RUNTIME HEALTH"

  curl -i -s --max-time 10 http://localhost:3000/api/tasks/health || true

  echo ""

  echo "TASK API ARTIFACT PRESENCE"

  curl -s --max-time 10 http://localhost:3000/api/tasks | grep -o '"artifact"' | head || true

  echo ""

  echo "STATIC JS ARTIFACT LINE PRESENCE"

  curl -s --max-time 10 http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -n "Artifact:" | head || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 120 motherboard_systems_hq-dashboard-1 || true

} | tee checkpoints/PHASE719_PHASE530_ARTIFACT_LINE_V2_VERIFY.txt

git add "$TARGET" \

  PHASE719_PATCH_PHASE530_ARTIFACT_LINE_V2.sh \

  checkpoints/PHASE719_PHASE530_PRE_ARTIFACT_LINE_V2.js \

  checkpoints/PHASE719_PHASE530_POST_ARTIFACT_LINE_V2.js \

  checkpoints/PHASE719_PHASE530_ARTIFACT_LINE_V2_VERIFY.txt

git commit -m "Phase 719: surface artifact line in recent tasks"

git push origin "$(git branch --show-current)"

echo "===== PHASE530 ARTIFACT LINE V2 PATCH COMPLETE ====="

