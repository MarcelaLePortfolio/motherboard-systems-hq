#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== RUN OPERATIONAL PACKAGE AUTHORITY GAP INSPECTION FIX ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== VERIFY EXISTING FIX SCRIPT ==="
test -f fix-operational-package-authority-gap-inspection.sh

echo
echo "=== EXECUTE EXISTING FIX ==="
bash fix-operational-package-authority-gap-inspection.sh
