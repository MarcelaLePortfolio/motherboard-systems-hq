#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== FIX VALIDATION LINEAGE RUNNER PERMISSION ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== FAILURE CLASSIFICATION ==="
echo "FAILED_HYPOTHESIS=NO"
echo "REPOSITORY_DEFECT_ESTABLISHED=NO"
echo "RUNNER_PERMISSION_DEFECT=YES"
echo "DEFECT=RUN_VALIDATION_CANONICAL_LINEAGE_ENFORCEMENT_OPTIONS_NOT_EXECUTABLE"
echo "PRODUCTION_CHANGE=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== REPAIR EXECUTABLE BIT ==="
chmod +x run-validation-canonical-lineage-enforcement-options.sh
chmod +x inspect-validation-canonical-lineage-enforcement-options.sh

echo
echo "=== VERIFY MODES ==="
git ls-files -s run-validation-canonical-lineage-enforcement-options.sh
git ls-files -s inspect-validation-canonical-lineage-enforcement-options.sh
ls -l run-validation-canonical-lineage-enforcement-options.sh
ls -l inspect-validation-canonical-lineage-enforcement-options.sh

echo
echo "=== STAGE MODE REPAIR ==="
git add run-validation-canonical-lineage-enforcement-options.sh \
        inspect-validation-canonical-lineage-enforcement-options.sh

echo
echo "=== VERIFY STAGED DIFF ==="
git diff --cached --summary
git diff --cached -- run-validation-canonical-lineage-enforcement-options.sh \
                     inspect-validation-canonical-lineage-enforcement-options.sh

echo
echo "=== COMMIT AND PUSH MODE REPAIR ==="
git commit -m "Fix Validation lineage inspection runner permissions"
git push

echo
echo "=== EXECUTE INSPECTION ==="
./run-validation-canonical-lineage-enforcement-options.sh
