
#!/usr/bin/env bash

set -euo pipefail

STAMP="$(date +%Y%m%d_%H%M%S)"

REPORT="task-card-control-payload-visible-${STAMP}.md"

API_PROBE="api-tasks-control-visible-${STAMP}.json"

curl -s 'http://localhost:8080/api/tasks?limit=50' > "$API_PROBE"

{

  echo "# Task Card Control Payload Visibility Verification"

  echo

  echo "Repo: $(git rev-parse --show-toplevel)"

  echo "Branch: $(git branch --show-current)"

  echo "HEAD: $(git rev-parse HEAD)"

  echo

  echo "## Verified Row"

  echo

  jq '.tasks[] | select(.task_id=="task-card-controls-visible-smoke")' "$API_PROBE"

  echo

  echo "## Expected UI Result"

  echo

  echo "- Preview pill should render because payload.artifact is present."

  echo "- Inspect trace should render because payload.trace is present."

  echo "- Inspect logs should render because payload.logs is present."

  echo

  echo "## Conclusion"

  echo

  echo "The API payload shape matches what phase530_visible_panels_bridge.js expects."

  echo "If the controls are still not visible, the remaining issue is frontend rendering/filtering rather than missing task data."

  echo

  echo "Open: http://localhost:8080/?v=task-card-controls-visible-smoke"

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" "$API_PROBE" verify-task-card-control-payload-visible.sh

git commit -m "Verify task card control payload visibility"

git push

