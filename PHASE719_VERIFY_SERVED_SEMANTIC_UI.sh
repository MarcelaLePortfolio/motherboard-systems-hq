
#!/bin/bash

set -euo pipefail

echo "===== PHASE 719 SERVED SEMANTIC UI VERIFY ====="

curl -sS http://localhost:3000/js/phase530_visible_panels_bridge.js \

  | grep -n "Recovery Artifact\|Execution Plan\|Completion Summary\|Needs Review\|Actionable" \

  | head -20

echo ""

echo "Open http://localhost:3000, click a completed task Preview, and confirm chips now show semantic labels."

echo "===== COMPLETE ====="

