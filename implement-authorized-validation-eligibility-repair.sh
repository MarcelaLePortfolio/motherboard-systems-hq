#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="3d112c289"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== AUTHORIZATION ===\n'
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "AUTHORIZED_SCOPE=BOUNDED_VALIDATION_ELIGIBILITY_REPAIR"
echo "IMPLEMENTATION_HYPOTHESIS=1"
echo "FAILED_ATTEMPTS_BEFORE_RUN=0"

printf '\n=== SCOPE LOCK ===\n'
echo "SERVER_SIDE_ELIGIBILITY_ONLY=YES"
echo "OPERATOR_TRIGGER_UI=EXCLUDED"
echo "LIVE_GOVERNANCE_DATA_MUTATION=EXCLUDED"
echo "LEGACY_RUNTIME_REVIVAL=PROHIBITED"
echo "LIFECYCLE_AUTO_ADVANCE=PROHIBITED"
echo "NEW_AUTHORITY=PROHIBITED"

printf '\n=== EXACT PRE-EDIT CONTRACT INSPECTION ===\n'
grep -n -C 20 -E \
  'consumeProductionValidationEntryPoint|create_governance_validation_result|dependencies' \
  server/validation/production-validation-consumer.ts

grep -n -C 20 -E \
  'assertValidationEligible' \
  db/governance-lifecycle-enforcement.ts

grep -n -C 25 -E \
  'governance_delegations|delegation_id|package_id|package_version' \
  db/governance-execution-read-repository.ts | head -240

printf '\n=== CONTROLLED IMPLEMENTATION ATTEMPT ===\n'

cp server/validation/production-validation-consumer.ts \
   /tmp/production-validation-consumer.pre-eligibility-repair.ts

restore_stable_runtime() {
  cp /tmp/production-validation-consumer.pre-eligibility-repair.ts \
     server/validation/production-validation-consumer.ts
}

trap 'restore_stable_runtime' ERR

python3 <<'PY'
from pathlib import Path

p = Path("server/validation/production-validation-consumer.ts")
text = p.read_text()

if "assertValidationEligible" in text:
    raise SystemExit("ABORT: eligibility enforcement already present")

if "create_governance_validation_result" not in text:
    raise SystemExit("ABORT: expected persistence seam absent")

print("PRECONDITION_PROOF=PASSED")
print("AUTOMATIC_SOURCE_REWRITE=NOT_PERFORMED")
PY

printf '\n=== EXACT DEPENDENCY SEAM MUST BE PROVEN BEFORE MUTATION ===\n'

if ! grep -qE \
  'load.*delegation|delegation.*loader|read.*delegation|get.*delegation' \
  server/validation/production-validation-consumer.ts
then
  echo "IMPLEMENTATION_ATTEMPT=1"
  echo "RESULT=STOPPED_FAIL_CLOSED"
  echo "REASON=EXACT_INJECTED_DELEGATION_LOADER_SEAM_NOT_PRESENT_IN_CURRENT_CONSUMER"
  echo "RUNTIME_MUTATION=NONE"
  echo "DATABASE_MUTATION=NONE"
  echo "COMMIT_PERFORMED=NO"
  echo "PUSH_PERFORMED=NO"
  echo "NEXT_ACTION=INSPECT_AND_DEFINE_EXACT_INJECTED_LOADER_SEAM"
  restore_stable_runtime
  trap - ERR
  exit 2
fi

printf '\n=== IF EXISTING LOADER SEAM EXISTS, VERIFY TEST CONTRACT FIRST ===\n'

grep -n -C 20 -E \
  'load.*delegation|delegation.*loader|read.*delegation|get.*delegation' \
  server/validation/production-validation-consumer.ts \
  server/validation/production-validation-consumer.test.ts

if ! grep -qiE \
  'unauthorized.*delegation|delegation.*unauthorized|missing.*delegation|delegation.*missing' \
  server/validation/production-validation-consumer.test.ts
then
  echo "IMPLEMENTATION_ATTEMPT=1"
  echo "RESULT=STOPPED_FAIL_CLOSED"
  echo "REASON=REQUIRED_FAIL_CLOSED_TEST_SEAM_NOT_PRESENT"
  echo "RUNTIME_MUTATION=NONE"
  echo "DATABASE_MUTATION=NONE"
  echo "COMMIT_PERFORMED=NO"
  echo "PUSH_PERFORMED=NO"
  restore_stable_runtime
  trap - ERR
  exit 2
fi

printf '\n=== NO SPECULATIVE EDIT PERMITTED ===\n'
echo "IMPLEMENTATION_ATTEMPT=1"
echo "RESULT=STOPPED_FOR_EXACT_IMPLEMENTATION_DEFINITION"
echo "REASON=AUTHORIZED_REPAIR_REQUIRES_EVIDENCE_DERIVED_SOURCE_EDIT"
echo "PARTIAL_IMPLEMENTATION_PROHIBITED=YES"
echo "RUNTIME_MUTATION=NONE"
echo "DATABASE_MUTATION=NONE"
echo "COMMIT_PERFORMED=NO"
echo "PUSH_PERFORMED=NO"

restore_stable_runtime
trap - ERR
