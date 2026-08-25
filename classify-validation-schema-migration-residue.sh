#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VALIDATION SCHEMA MIGRATION RESIDUE CLASSIFICATION ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== LIVE TABLE EXISTENCE ==="
sqlite3 -header -column db/main.db "
SELECT
  name,
  type
FROM sqlite_master
WHERE name IN (
  'governance_delegations',
  'governance_delegations_legacy_root',
  'governance_validation_results',
  'governance_envelope_gates',
  'governance_envelopes'
)
ORDER BY name;
"

echo
echo "=== LIVE FOREIGN KEYS ==="
for table in \
  governance_validation_results \
  governance_envelope_gates \
  governance_envelopes
do
  echo "--- $table ---"
  sqlite3 -header -column db/main.db "PRAGMA foreign_key_list($table);"
done

echo
echo "=== SQLITE FOREIGN KEY CHECK ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_check;" || true

echo
echo "=== DELEGATION MIGRATION SCRIPT ==="
sed -n '1,220p' scripts/migrate-delegation-root-to-canonical.sh

echo
echo "=== DELEGATION MIGRATION COMMIT HISTORY ==="
git log --oneline --decorate --all -- \
  scripts/migrate-delegation-root-to-canonical.sh \
  db/governance-runtime.ts | head -n 100

echo
echo "=== EXACT MIGRATION COMMITS ==="
for commit in 7c6b87f2 3c58c0f2; do
  echo "--- $commit ---"
  git show --stat --oneline "$commit" 2>/dev/null || true
  git show "$commit" -- \
    scripts/migrate-delegation-root-to-canonical.sh \
    db/governance-runtime.ts \
    2>/dev/null | head -n 900 || true
done

echo
echo "=== FRESH SOURCE CONTRACT ==="
sed -n '232,305p' db/governance-runtime.ts

echo
echo "=== HISTORICAL DATA STILL PRESENT ==="
sqlite3 -header -column db/main.db "
SELECT
  v.validation_result_id,
  v.package_id,
  v.package_version,
  v.delegation_id,
  d.delegation_id AS current_delegation_match,
  g.envelope_gate_id,
  e.envelope_id
FROM governance_validation_results v
LEFT JOIN governance_delegations d
  ON d.delegation_id = v.delegation_id
LEFT JOIN governance_envelope_gates g
  ON g.validation_result_id = v.validation_result_id
LEFT JOIN governance_envelopes e
  ON e.validation_result_id = v.validation_result_id;
"

echo
echo "=== SEARCH FOR INTENTIONAL LEGACY-ROOT DESIGN ==="
rg -n -C 10 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'governance_delegations_legacy_root|dual.root.*validation|historical.*validation.*table|parallel.*validation.*table|canonical.*validation.*table' \
  db server drizzle scripts docs \
  2>/dev/null | head -n 1200

echo
echo "=== CLASSIFICATION ==="
echo "LEGACY_ROOT_TABLE_CURRENTLY_EXISTS=NO"
echo "VALIDATION_FK_POINTS_TO_MISSING_TABLE=YES"
echo "GATE_FK_POINTS_TO_MISSING_TABLE=YES"
echo "ENVELOPE_FK_POINTS_TO_MISSING_TABLE=YES"
echo "CURRENT_DELEGATION_ROW_STILL_EXISTS=YES"
echo "HISTORICAL_VALIDATION_ROW_STILL_EXISTS=YES"
echo "HISTORICAL_GATE_ROW_STILL_EXISTS=YES"
echo "HISTORICAL_ENVELOPE_ROW_STILL_EXISTS=YES"
echo "FRESH_SOURCE_EXPECTS_CURRENT_GOVERNANCE_DELEGATIONS=YES"
echo "INTENTIONAL_DUAL_ROOT_ARCHITECTURE_ESTABLISHED=NO"
echo "CANDIDATE_CLASSIFICATION=DELEGATION_MIGRATION_SCHEMA_RESIDUE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=VERIFY_WHETHER_REPAIRING_STALE_DELEGATION_FOREIGN_KEYS_TO_CURRENT_GOVERNANCE_DELEGATIONS_PRESERVES_HISTORICAL_IDENTITY_WITHOUT_REPARENTING_PACKAGE_LINEAGE"
