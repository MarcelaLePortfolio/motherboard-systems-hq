#!/usr/bin/env bash
set -euo pipefail

printf '\n=== GOVERNANCE RUNTIME INITIALIZERS ===\n'
grep -RInE \
  'ensureGovernanceRuntimeTables|ensureGovernanceLifecycleEventTable|governance_lifecycle_events|CREATE TABLE' \
  db \
  --include='*.ts' \
  --include='*.mjs' \
  2>/dev/null || true

printf '\n=== INITIALIZER CALL SITES ===\n'
grep -RInE \
  'ensureGovernanceRuntimeTables\(|ensureGovernanceLifecycleEventTable\(' \
  db server routes \
  --include='*.ts' \
  --include='*.mjs' \
  2>/dev/null || true

printf '\n=== SERVER STARTUP IMPORTS ===\n'
sed -n '1,220p' server/index.ts

printf '\n=== GOVERNANCE RUNTIME SOURCE ===\n'
sed -n '1,320p' db/governance-runtime.ts

printf '\n=== GOVERNANCE LIFECYCLE PERSISTENCE SOURCE ===\n'
sed -n '1,320p' db/governance-lifecycle-persistence.ts

printf '\n=== CURRENT GOVERNANCE TABLES ===\n'
sqlite3 db/main.db "
SELECT name
FROM sqlite_master
WHERE type = 'table'
  AND name LIKE 'governance_%'
ORDER BY name;
"

printf '\n=== LIFECYCLE TABLE DEFINITION ===\n'
sqlite3 db/main.db "
SELECT sql
FROM sqlite_master
WHERE type = 'table'
  AND name = 'governance_lifecycle_events';
"

printf '\n=== REPOSITORY STATE ===\n'
git status --short
