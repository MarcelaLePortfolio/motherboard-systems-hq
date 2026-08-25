#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== RUN VALIDATION CANONICAL LINEAGE ENFORCEMENT OPTIONS ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== VERIFY INSPECTION SCRIPT PRESENT ==="
test -f inspect-validation-canonical-lineage-enforcement-options.sh
chmod +x inspect-validation-canonical-lineage-enforcement-options.sh

echo
echo "=== EXECUTE INSPECTION ==="
./inspect-validation-canonical-lineage-enforcement-options.sh

echo
echo "=== POST-RUN WORKTREE ==="
git status --short
