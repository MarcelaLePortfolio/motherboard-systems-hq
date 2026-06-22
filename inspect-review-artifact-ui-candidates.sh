
#!/usr/bin/env bash

set -euo pipefail

echo "--- authoritative approval/review doctrine anchors ---"

sed -n '780,825p' AUTHORITATIVE_EXECUTION_CORRIDOR.txt

echo

sed -n '1116,1242p' AUTHORITATIVE_EXECUTION_CORRIDOR.txt

echo

echo "--- current approval artifact builder ---"

sed -n '1,220p' server/execution/build-approval-artifact.mjs

echo

echo "--- current governed planning bundle builder ---"

sed -n '1,260p' server/execution/build-governed-planning-artifact-bundle.mjs

echo

echo "--- likely UI homes for reviewable planning artifacts ---"

git grep -nEi "execution inspector|operator guidance|recent tasks|artifact|approval|review|card|panel" -- \

  public/js/phase530_visible_panels_bridge.js \

  public/js/phase565_recent_tasks_wire.js \

  public/js/task-events-sse-client.js \

  public/index.html \

  public/dashboard.html \

  ':!public/bundle.js' \

  ':!public/bundle.js.map' || true

git add inspect-review-artifact-ui-candidates.sh

git commit -m "Add review artifact UI candidate inspection"

git push

