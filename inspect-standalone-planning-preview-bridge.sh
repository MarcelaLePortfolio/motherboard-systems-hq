
#!/usr/bin/env bash

set -euo pipefail

echo "--- standalone artifact/event infrastructure ---"

sed -n '1,120p' server/artifacts.mjs

echo

echo "--- artifact route mounting ---"

git grep -nE "artifacts|mountArtifacts|/events/artifacts|/api/artifacts" -- server.mjs server routes scripts public/js ':!public/bundle.js' ':!public/bundle.js.map' || true

echo

echo "--- artifact frontend consumer ---"

sed -n '1,120p' public/js/project-visual-output.js

echo

echo "--- dashboard artifact visual output mounts ---"

grep -nE "project-visual-output|artifacts|visual output|preview" public/index.html public/dashboard.html || true

echo

echo "--- existing governed planning route imports and response assembly ---"

sed -n '1,40p' server/routes/governed-planning-route.mjs

sed -n '286,338p' server/routes/governed-planning-route.mjs

echo

echo "--- planning bundle contains reviewable material ---"

grep -nE "response|reconciliation|audit_ledger|execution_authority|planned_patches|mutation_performed|shell_execution_performed|autonomous_execution_performed" server/execution/build-governed-planning-artifact-bundle.mjs

echo

echo "--- preview renderer reusable entrypoints in phase530 ---"

grep -nE "phase719RenderMarkdownArtifactPreview|phase719OpenPreviewModal|phase719EnsurePreviewModal|data-phase719-preview-artifact|artifact-preview" public/js/phase530_visible_panels_bridge.js

