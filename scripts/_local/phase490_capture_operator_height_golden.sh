#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_490_OPERATOR_HEIGHT_GOLDEN_BASELINE.txt"
CURRENT_COMMIT="$(git rev-parse HEAD)"

{
  echo "PHASE 490 — OPERATOR HEIGHT GOLDEN BASELINE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Commit: $CURRENT_COMMIT"
  echo
  echo "STATUS"
  echo "- Operator Chat and Delegation panel heights MATCH"
  echo "- Telemetry scrolling behavior preserved"
  echo "- Hidden operator tab stacking regression resolved"
  echo
  echo "DO NOT LOSE"
  echo "- public/js/phase489_panel_height_sync.js"
  echo "- public/index.html script mount for phase489_panel_height_sync.js"
  echo
  echo "RESTORE COMMAND"
  echo "git restore --source=$CURRENT_COMMIT -- public/js/phase489_panel_height_sync.js public/index.html"
  echo
  echo "REBUILD COMMAND"
  echo "docker compose up -d --build"
  echo
  echo "VERIFY"
  echo "- Chat tab and Delegation tab must render at matching heights"
  echo "- Delegation tab must not stack underneath Chat"
  echo "- Telemetry console layout must remain intact"
  echo
  echo "TAG CANDIDATE"
  echo "phase490-operator-height-golden"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"

git tag -f phase490-operator-height-golden "$CURRENT_COMMIT"

echo
echo "Created/updated tag: phase490-operator-height-golden -> $CURRENT_COMMIT"
