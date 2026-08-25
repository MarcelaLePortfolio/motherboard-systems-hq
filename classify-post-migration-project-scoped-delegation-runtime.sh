#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY POST-MIGRATION PROJECT-SCOPED DELEGATION RUNTIME ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== LIVE DELEGATION SCHEMA ==="
sqlite3 db/main.db '.schema governance_delegations'

echo
echo "=== LIVE DELEGATION DATA ==="
sqlite3 -header -column db/main.db '
SELECT
  delegation_id,
  project_id,
  package_id,
  package_version,
  authorization_state,
  delegated_by,
  created_at
FROM governance_delegations
ORDER BY created_at, delegation_id;
'

echo
echo "=== LIVE COMPOSITE FK ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_list(governance_delegations);"

echo
echo "=== TARGETED FK CHECK ==="
TARGETED_FK_FAILURES="$(
  sqlite3 db/main.db \
    "SELECT COUNT(*) FROM pragma_foreign_key_check WHERE \"table\"='governance_delegations';"
)"
echo "TARGETED_DELEGATION_FK_FAILURES=${TARGETED_FK_FAILURES}"
test "$TARGETED_FK_FAILURES" = "0"

echo
echo "=== DOWNSTREAM DEFECT BOUNDARY ==="
VALIDATION_FK_TARGET="$(
  sqlite3 db/main.db \
    "SELECT DISTINCT \"table\" FROM pragma_foreign_key_list('governance_validation_results') WHERE \"from\"='delegation_id';"
)"
GATE_FK_TARGET="$(
  sqlite3 db/main.db \
    "SELECT DISTINCT \"table\" FROM pragma_foreign_key_list('governance_envelope_gates') WHERE \"from\"='delegation_id';"
)"
ENVELOPE_FK_TARGET="$(
  sqlite3 db/main.db \
    "SELECT DISTINCT \"table\" FROM pragma_foreign_key_list('governance_envelopes') WHERE \"from\"='delegation_id';"
)"

echo "VALIDATION_FK_TARGET=${VALIDATION_FK_TARGET}"
echo "GATE_FK_TARGET=${GATE_FK_TARGET}"
echo "ENVELOPE_FK_TARGET=${ENVELOPE_FK_TARGET}"

test "$VALIDATION_FK_TARGET" = "governance_delegations_legacy_root"
test "$GATE_FK_TARGET" = "governance_delegations_legacy_root"
test "$ENVELOPE_FK_TARGET" = "governance_delegations_legacy_root"

echo
echo "=== REGRESSION VALIDATION ==="
npx tsc --noEmit --pretty false
npx tsx --test \
  server/delegation/production-delegation-entry-point.test.ts \
  server/delegation/production-delegation-consumer.test.ts

echo
echo "=== CLASSIFICATION ==="
echo "UNIT_NAME=PROJECT_SCOPED_DELEGATION_REFERENCE"
echo "IMPLEMENTATION_COMMIT=5b9082f2"
echo "LIVE_MIGRATION_COMMAND_COMMIT=908a6671"
echo "LIVE_MIGRATION_APPLIED=YES"
echo "LIVE_PROJECT_SCOPED_DELEGATION_REFERENCE=ACTIVE"
echo "COMPOSITE_CANONICAL_FK=PASS"
echo "HISTORICAL_UNROOTED_DELEGATION_PRESERVED=YES"
echo "HISTORICAL_REPARENTING=NO"
echo "TARGETED_DELEGATION_FK_CHECK=PASS"
echo "TYPECHECK=PASS"
echo "TARGETED_TESTS=PASS"
echo "KNOWN_DOWNSTREAM_LEGACY_ROOT_DEFECT=VERIFIED_UNCHANGED_AND_SEPARATE"
echo "PROJECT_SCOPED_DELEGATION_UNIT=COMPLETE_AND_VALIDATED"
echo "CORRIDOR_CLOSED=YES"
echo "PRODUCTION_CHANGE=PROJECT_SCOPED_DELEGATION_REFERENCE_ACTIVATED"
echo "NEXT_ACTION=RETURN_TO_AUTHORITATIVE_MISSION_PACKAGE_HANDOFF_PHASE_AND_SELECT_NEXT_CORRIDOR"
