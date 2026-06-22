
#!/usr/bin/env bash

set -euo pipefail

echo "--- search review / approval / planned work language ---"

git grep -nEi "review.*plan|planned work|approve|approval|approval gate|before execution|pre-execution|human approval|operator approval|user approval|execution review|review gate" -- \

  server docs scripts public '*.md' '*.txt' '*.mjs' '*.js' \

  ':!public/bundle.js' \

  ':!public/bundle.js.map' \

  ':!backups/**' \

  ':!scripts_backup/**' \

  ':!scripts_backup_2/**' \

  ':!_dashboard_candidate_previews/**' \

  ':!DASHBOARD_UI_RECOVERY_ANCHORS/**' || true

echo

echo "--- governed planning / approval artifacts ---"

git grep -nEi "approval_gate|approval-gate|approval artifact|buildApproval|execution_authority|planning artifact|artifact bundle|governed_planning_artifact" -- \

  server/execution server/routes server/api docs '*.md' '*.txt' '*.mjs' \

  ':!backups/**' \

  ':!scripts_backup/**' \

  ':!scripts_backup_2/**' || true

echo

echo "--- UI surfaces that may serve reviewable artifacts ---"

git grep -nEi "recent tasks|telemetry|artifact|approval|review|planned|execution inspector|operator guidance|task events|card|panel" -- \

  public/js public/dashboard.html public/index.html \

  ':!public/bundle.js' \

  ':!public/bundle.js.map' || true

echo

echo "--- inspect current governed planning route response shape ---"

sed -n '1,420p' server/routes/governed-planning-route.mjs

echo

echo "--- inspect approval gate and artifact bundle builders ---"

sed -n '1,220p' server/execution/execution-approval-gate.mjs

echo

sed -n '1,260p' server/execution/build-approval-artifact.mjs

echo

sed -n '1,260p' server/execution/build-governed-planning-artifact-bundle.mjs

git add inspect-user-review-before-execution.sh

git commit -m "Add user review before execution inspection"

git push

