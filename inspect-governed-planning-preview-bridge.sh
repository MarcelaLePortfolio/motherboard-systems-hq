
#!/usr/bin/env bash

set -euo pipefail

REPORT="governed-planning-preview-bridge-inspection.txt"

{

  echo "GOVERNED PLANNING PREVIEW BRIDGE INSPECTION"

  echo

  echo "--- current head ---"

  git log --oneline -8

  echo

  echo "--- governed planning route surfaces ---"

  rg -n -i "governed planning|planning_only|artifact bundle|buildGovernedPlanningArtifactBundle|bundle" server routes public docs/contracts . --glob '!node_modules/**' --glob '!backups/**' || true

  echo

  echo "--- governed planning route file ---"

  sed -n '1,260p' server/routes/governed-planning-route.mjs 2>/dev/null || true

  echo

  echo "--- planning artifact bundle builder ---"

  sed -n '1,260p' server/execution/build-governed-planning-artifact-bundle.mjs 2>/dev/null || true

  echo

  echo "--- approval artifact / gate files ---"

  sed -n '1,220p' server/execution/build-approval-artifact.mjs 2>/dev/null || true

  echo

  sed -n '1,260p' server/execution/execution-approval-gate.mjs 2>/dev/null || true

  echo

  echo "--- dashboard candidate mount locations ---"

  rg -n -i "Execution Inspector|Operator Guidance|Planning|Approval Required|artifact|preview|task-events-card|recent-tasks-card|observational-panels|operator-guidance-panel" public/dashboard.html public/js public/css --glob '!bundle.js' --glob '!bundle.js.map' || true

  echo

  echo "--- task-coupled artifact preview renderer boundaries ---"

  rg -n -i "artifact-preview|data-task-id|data-artifact|preview modal|No task id available|/api/tasks/.*/artifact-preview" public/js public/dashboard.html server routes --glob '!bundle.js' --glob '!bundle.js.map' || true

  echo

  echo "--- existing planning preview card shell ---"

  sed -n '1,240p' public/js/planning-preview-card.js 2>/dev/null || true

} | tee "$REPORT"

cat > governed-planning-preview-bridge-inspection-finding.txt << 'NOTE'

GOVERNED PLANNING PREVIEW BRIDGE INSPECTION FINDING

Finding Status: INSPECTION ONLY

This pass inspects the smallest safe bridge for displaying the governed planning artifact bundle as a read-only user review surface.

Scope boundaries:

- No runtime mutation.

- No shell execution.

- No autonomous execution.

- No approval implementation.

- No preview-confirmation implementation.

- No UI patch beyond inspection artifacts.

Current question:

Where can the governed planning artifact bundle be displayed as a standalone preview/review artifact without representing it as a task?

NOTE

git add inspect-governed-planning-preview-bridge.sh governed-planning-preview-bridge-inspection.txt governed-planning-preview-bridge-inspection-finding.txt

git commit -m "Inspect governed planning preview bridge"

git push

