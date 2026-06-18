
#!/usr/bin/env bash

set -euo pipefail

echo "--- current served dashboard route ---"

grep -nE 'app.get\("/dashboard"|sendFile|public/dashboard.html' server.mjs

echo

echo "--- served dashboard existing script/style anchors ---"

grep -nE 'phase530_visible_panels_bridge|phase565_recent_tasks_wire|phase61_tabs_workspace|project-visual-output|dashboard-bundle-entry|bundle.js|dashboard-delegation|task-events-sse-client' public/dashboard.html || true

echo

echo "--- index-only anchored script candidates ---"

tmp_dashboard="$(mktemp)"

tmp_index="$(mktemp)"

trap 'rm -f "$tmp_dashboard" "$tmp_index"' EXIT

grep -oE 'src="[^"]+"' public/dashboard.html | sort -u > "$tmp_dashboard" || true

grep -oE 'src="[^"]+"' public/index.html | sort -u > "$tmp_index" || true

comm -13 "$tmp_dashboard" "$tmp_index" || true

echo

echo "--- served dashboard planning preview candidate mount areas ---"

grep -nEi 'recent tasks|task events|operator guidance|telemetry|observational|project-visual-output|artifact|preview|planning' public/dashboard.html | head -160 || true

echo

echo "--- current dashboard rollback commit ---"

git log --oneline -5

