#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

mkdir -p docs

SUMMARY_OUT="docs/phase470_9_probe_regex_fix_and_summary.txt"

cat > "$SUMMARY_OUT" <<'EOT'
PHASE 470.9 — PROBE REGEX FIX SUMMARY
====================================

SOURCE: docs/phase470_8_remaining_live_dashboard_surfaces.txt

STEP 1 — Count lines
EOT

{
  rg -n "EventSource count:|setInterval count:|setTimeout count:|fetch count:|CLASSIFICATION:" docs/phase470_8_remaining_live_dashboard_surfaces.txt || true
  echo
  echo "STEP 2 — Heavy request lines"
  rg -n "GET /events/ops count:|GET /events/task-events count:|GET /api/tasks count:|GET /api/runs count:" docs/phase470_8_remaining_live_dashboard_surfaces.txt || true
  echo
  echo "STEP 3 — Next action"
  echo "- Use the classification from phase470.8 as the next isolation target."
} >> "$SUMMARY_OUT"

echo "Wrote $SUMMARY_OUT"
sed -n '1,220p' "$SUMMARY_OUT"
