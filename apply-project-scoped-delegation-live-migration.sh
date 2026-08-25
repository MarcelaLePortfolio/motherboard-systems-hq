#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

AUTHORIZED_ANCESTOR="d096d6d4"
git merge-base --is-ancestor "$AUTHORIZED_ANCESTOR" HEAD || {
  echo "Authorized live-migration checkpoint is not an ancestor of HEAD; refusing migration."
  exit 1
}

test -z "$(git status --short)" || {
  echo "Worktree is not clean; refusing live migration."
  git status --short
  exit 1
}

echo "=== PRE-MIGRATION VALIDATION ==="
npx tsc --noEmit --pretty false
npx tsx --test \
  server/delegation/production-delegation-entry-point.test.ts \
  server/delegation/production-delegation-consumer.test.ts
node scripts/validate-project-scoped-delegation-reference.mjs

PRE_DELEGATION_COUNT="$(sqlite3 db/main.db 'SELECT COUNT(*) FROM governance_delegations;')"
PRE_HISTORICAL_COUNT="$(sqlite3 db/main.db "SELECT COUNT(*) FROM governance_delegations WHERE delegation_id='corridor-delegation' AND package_id='corridor-smoke' AND package_version=1;")"

test "$PRE_DELEGATION_COUNT" = "1"
test "$PRE_HISTORICAL_COUNT" = "1"

echo "=== BACKUP LIVE DATABASE ==="
BACKUP="db/main.db.pre-project-scoped-delegation-$(date +%Y%m%d_%H%M%S).bak"
cp db/main.db "$BACKUP"
echo "BACKUP=$BACKUP"

echo "=== APPLY AUTHORIZED MIGRATION ==="
sqlite3 db/main.db < drizzle/0010_project_scoped_delegation_reference.sql

echo "=== POST-MIGRATION VALIDATION ==="
PROJECT_ID_COLUMN="$(
  sqlite3 db/main.db \
    "SELECT COUNT(*) FROM pragma_table_info('governance_delegations') WHERE name='project_id';"
)"
test "$PROJECT_ID_COLUMN" = "1"

POST_DELEGATION_COUNT="$(sqlite3 db/main.db 'SELECT COUNT(*) FROM governance_delegations;')"
POST_HISTORICAL_COUNT="$(sqlite3 db/main.db "SELECT COUNT(*) FROM governance_delegations WHERE delegation_id='corridor-delegation' AND package_id='corridor-smoke' AND package_version=1 AND project_id IS NULL;")"

test "$POST_DELEGATION_COUNT" = "$PRE_DELEGATION_COUNT"
test "$POST_HISTORICAL_COUNT" = "1"

COMPOSITE_FK_COUNT="$(
  sqlite3 db/main.db "
    SELECT COUNT(*)
    FROM pragma_foreign_key_list('governance_delegations')
    WHERE \"table\"='matilda_canonical_packages'
      AND (
        (\"from\"='project_id' AND \"to\"='project_id') OR
        (\"from\"='package_id' AND \"to\"='package_id') OR
        (\"from\"='package_version' AND \"to\"='package_version')
      );
  "
)"
test "$COMPOSITE_FK_COUNT" = "3"

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

test "$VALIDATION_FK_TARGET" = "governance_delegations_legacy_root"
test "$GATE_FK_TARGET" = "governance_delegations_legacy_root"
test "$ENVELOPE_FK_TARGET" = "governance_delegations_legacy_root"

TARGETED_FK_FAILURES="$(
  sqlite3 db/main.db \
    "SELECT COUNT(*) FROM pragma_foreign_key_check WHERE \"table\"='governance_delegations';"
)"
test "$TARGETED_FK_FAILURES" = "0"

echo "=== LIVE MIGRATION RESULT ==="
echo "LIVE_MIGRATION_AUTHORIZED=YES"
echo "LIVE_MIGRATION_APPLIED=YES"
echo "PROJECT_SCOPED_DELEGATION_COLUMN=PRESENT"
echo "HISTORICAL_UNROOTED_DELEGATION_PRESERVED=YES"
echo "HISTORICAL_REPARENTING=NO"
echo "COMPOSITE_CANONICAL_FK=PASS"
echo "TARGETED_DELEGATION_FK_CHECK=PASS"
echo "KNOWN_DOWNSTREAM_LEGACY_ROOT_DEFECT=VERIFIED_UNCHANGED_AND_SEPARATE"
echo "CORRIDOR_CLOSED=NO"
echo "NEXT_ACTION=CLASSIFY_POST_MIGRATION_RUNTIME_STATE"
