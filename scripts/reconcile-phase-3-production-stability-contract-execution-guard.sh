#!/usr/bin/env bash
set -euo pipefail

echo "=== RECONCILE PHASE 3 PRODUCTION STABILITY CONTRACT EXECUTION GUARD ==="

target="scripts/define-phase-3-production-stability-validation-contract.sh"

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
test -f "$target"
git merge-base --is-ancestor d8256e8d HEAD

python3 - <<'PY'
from pathlib import Path

path = Path("scripts/define-phase-3-production-stability-validation-contract.sh")
text = path.read_text()

old = '''echo
echo "=== VERIFY PHASE 3 STARTING BOUNDARY CHECKPOINT ==="
expected_head="7d9e1d77"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Phase 3 starting-boundary checkpoint $expected_head."
  exit 2
fi
'''

new = '''echo
echo "=== VERIFY PHASE 3 STARTING BOUNDARY CHECKPOINT ==="
canonical_starting_boundary="d8256e8d"

if ! git merge-base --is-ancestor "$canonical_starting_boundary" HEAD; then
  echo "STOP: canonical Phase 3 starting boundary $canonical_starting_boundary is not an ancestor of HEAD."
  exit 2
fi
'''

if old not in text:
    raise SystemExit("STOP: expected legacy exact-HEAD guard not found")

text = text.replace(old, new, 1)
path.write_text(text)
PY

echo
echo "=== VERIFY BOUNDED CHANGE ==="
git diff -- scripts/define-phase-3-production-stability-validation-contract.sh

git diff --check
git add scripts/define-phase-3-production-stability-validation-contract.sh
git diff --cached --check
git commit -m "Reconcile Phase 3 contract execution guard"
git push origin feature/support-source-references-runtime

echo
echo "=== VERIFY RECONCILED CONTRACT GUARD ==="
grep -nE 'canonical_starting_boundary|merge-base --is-ancestor|expected_head="7d9e1d77"' "$target" || true

echo "PRODUCTION_CHANGE=NONE"
echo "GENERATION_POLICY_CHANGE=NONE"
echo "SEMANTIC_CONTRACT_CHANGE=NONE"
echo "VALIDATION_CONTRACT_CHANGE=NONE"
echo "EXECUTION_GUARD_RECONCILED=YES"
