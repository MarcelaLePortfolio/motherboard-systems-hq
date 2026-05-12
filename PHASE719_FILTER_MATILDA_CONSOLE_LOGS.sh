
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 FILTER MATILDA CONSOLE LOGS ====="

echo ""

echo "Open DevTools Console and paste this filter exactly:"

echo ""

echo "[phase719-matilda-ui]"

echo ""

echo "Then ask:"

echo "what types of projects can this system build?"

echo ""

echo "Only the new Matilda tracing logs should remain visible."

echo ""

git add PHASE719_FILTER_MATILDA_CONSOLE_LOGS.sh

git commit -m "Phase 719: add Matilda console filter helper"

git push origin dev

