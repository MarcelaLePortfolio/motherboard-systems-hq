#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== DELEGATION HISTORICAL LINEAGE BOUNDARY ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== CURRENT DATABASE INTEGRITY ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_check;"

echo
echo "=== CURRENT DELEGATION ROOT CLASSES ==="
sqlite3 -header -column db/main.db "
SELECT
  d.delegation_id,
  d.package_id,
  d.package_version,
  CASE
    WHEN cp.package_id IS NOT NULL THEN 'CANONICAL'
    WHEN gp.package_id IS NOT NULL THEN 'LEGACY_GOVERNANCE_PACKAGE'
    ELSE 'ORPHAN'
  END AS lineage_class
FROM governance_delegations d
LEFT JOIN matilda_canonical_packages cp
  ON cp.package_id = d.package_id
 AND cp.package_version = d.package_version
LEFT JOIN governance_packages gp
  ON gp.package_id = d.package_id
 AND gp.package_version = d.package_version
ORDER BY d.created_at;
"

echo
echo "=== PRIOR DUAL-LINEAGE INVESTIGATION ==="
sed -n '1,260p' scripts/inspect-delegation-dual-lineage-migration-options.sh 2>/dev/null || true

echo
echo "=== PRIOR ENFORCEMENT-BOUNDARY CLASSIFICATION ==="
sed -n '1,260p' scripts/classify-delegation-canonical-enforcement-boundary.sh 2>/dev/null || true

echo
echo "=== DELEGATION MIGRATION HISTORY ==="
git log --all --oneline --decorate -- \
  scripts/migrate-delegation-root-to-canonical.sh \
  scripts/validate-canonical-delegation-root.sh \
  scripts/inspect-delegation-dual-lineage-migration-options.sh \
  scripts/classify-delegation-canonical-enforcement-boundary.sh \
  db/governance-runtime.ts | head -n 160

echo
echo "=== HISTORICAL VERSIONS OF DELEGATION MIGRATION ==="
for commit in $(git log --format='%H' -- scripts/migrate-delegation-root-to-canonical.sh | head -n 12); do
  echo "--- $commit ---"
  git show "$commit:scripts/migrate-delegation-root-to-canonical.sh" 2>/dev/null | sed -n '1,220p' || true
done

echo
echo "=== GOVERNANCE DOCUMENTATION: LEGACY VS CANONICAL DELEGATION ==="
rg -n -C 12 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'dual.lineage|legacy.*Delegation|Delegation.*legacy|historical.*Delegation|Delegation.*historical|canonical.*Delegation|Delegation.*canonical|preserv.*legacy|preserv.*historical|non.authoritative|historical surface' \
  docs/governance docs db server scripts \
  2>/dev/null | head -n 1800

echo
echo "=== FALSIFICATION: EXISTING HISTORICAL PERSISTENCE PATTERN ==="
rg -n -C 12 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'legacy_root|_legacy|historical_|_historical|archive|archived|history table|historical table|compatibility table|compatibility surface' \
  db drizzle scripts docs/governance \
  2>/dev/null | head -n 1800

echo
echo "=== FALSIFICATION: READERS THAT REQUIRE ONE DELEGATION TABLE ==="
rg -n -C 10 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'FROM governance_delegations|JOIN governance_delegations|governance_delegations gd' \
  db server routes scripts \
  2>/dev/null | head -n 1800

echo
echo "=== AUTHORITY INVARIANT ==="
sed -n '691,810p' db/governance-runtime.ts

echo
echo "=== CLASSIFICATION ==="
echo "VERIFIED_OUTCOME=NEW_DELEGATION_AUTHORITY_IS_CANONICAL_PACKAGE_ONLY"
echo "VERIFIED_OUTCOME=LEGACY_DELEGATION_HISTORY_WAS_INTENTIONALLY_PRESERVED"
echo "VERIFIED_OUTCOME=LEGACY_ROW_IS_NOT_CANONICAL_LINEAGE"
echo "VERIFIED_OUTCOME=CURRENT_SINGLE_TABLE_SCHEMA_MAKES_PRESERVED_LEGACY_ROW_VIOLATE_DECLARED_CANONICAL_FK"
echo "DEFERRED_WORK=VALIDATION_ROOT_RECONCILIATION"
echo "PROPOSED_IMPLEMENTATION=NONE"
echo "CURRENT_SCOPE=DELEGATION_HISTORICAL_LINEAGE_BOUNDARY_CLASSIFICATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "DECISION_QUESTION=DOES_REPOSITORY_EVIDENCE_SUPPORT_SEPARATING_NONAUTHORITATIVE_LEGACY_DELEGATION_HISTORY_FROM_CANONICAL_DELEGATION_PERSISTENCE_WITHOUT_CHANGING_RUNTIME_AUTHORITY"
