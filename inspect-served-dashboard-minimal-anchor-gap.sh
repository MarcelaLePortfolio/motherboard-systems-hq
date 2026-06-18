
#!/usr/bin/env bash

set -euo pipefail

echo "--- current served dashboard route ---"

grep -nE 'app.get\("/dashboard"|sendFile|public/dashboard.html' server.mjs

echo

echo "--- served dashboard existing script/style anchors ---"

grep -nE 'phase530_visible_panels_bridge|phase565_recent_tasks_wire|phase61_tabs_workspace|project-visual-output|dashboard-bundle-entry|bundle.js|dashboard-delegation|task-events-sse-client' public/dashboard.html || true

echo

echo "--- index-only anchored script candidates ---"

comm -13 \

  <(grep -oE 'src="[^"]+"' public/dashboard.html | sort -u) \

  <(grep -oE 'src="[^"]+"' public/index.html | sort -u) || true

echo

echo "--- served dashboard planning preview candidate mount areas ---"

grep -nEi 'recent tasks|task events|operator guidance|telemetry|observational|project-visual-output|artifact|preview|planning' public/dashboard.html | head -160 || true

echo

echo "--- current dashboard rollback commit ---"

git log --oneline -5

