
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 718 BROWSER RENDER CHECK ====="

echo ""

echo "[1] Open dashboard"

open "http://localhost:3000"

echo ""

echo "[2] Manual verification checklist"

echo "- Recent Tasks cards render normally"

echo "- lifecycle badge still visible"

echo "- strategy label visible on retry tasks"

echo "- retry of label visible on retry tasks"

echo "- Retry differently button still visible"

echo "- Requeue button still visible"

echo "- No overflow/layout breakage"

echo "- No console/runtime errors"

echo ""

echo "[3] Current HEAD"

git log --oneline --decorate -1

echo ""

echo "===== CHECK COMPLETE ====="

