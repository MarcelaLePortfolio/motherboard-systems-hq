
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 ARTIFACT PAYLOAD TRACE ====="

echo ""

echo "===== SEARCH: ARTIFACT API ROUTES ====="

grep -RIn "api/artifacts\\|/artifacts/" app server src . \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  2>/dev/null | head -120

echo ""

echo "===== SEARCH: PREVIEW RENDERER ====="

grep -RIn "rendered-artifact-preview\\|phase719-preview\\|srcdoc\\|iframe" public/js app server src . \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  2>/dev/null | head -160

echo ""

echo "===== SEARCH: ARTIFACT CREATION ====="

grep -RIn "artifact\\|outcome_preview\\|Build Path\\|Rendered Preview" worker app server src . \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  2>/dev/null | head -200

echo ""

echo "===== SAMPLE TASK API ====="

curl -s http://localhost:3000/api/tasks?limit=3 | head -80

echo ""

echo "===== PHASE 719 ARTIFACT PAYLOAD TRACE COMPLETE ====="

