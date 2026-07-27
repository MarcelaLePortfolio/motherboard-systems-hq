#!/usr/bin/env bash
set -euo pipefail

printf '\n=== GOVERNANCE RUNTIME EXPORTS ===\n'
grep -RInE \
  'export (function|type|interface|const)|governance_(packages|delegations|validation_results|envelope_gates|envelopes|lifecycle_events)' \
  db/governance-runtime.ts \
  db/governance-lifecycle-persistence.ts \
  db/governance-lifecycle-integration.ts \
  2>/dev/null || true

printf '\n=== GOVERNANCE API ROUTES ===\n'
grep -RInE \
  'governance|package|delegation|validation|envelope|lifecycle' \
  routes server \
  --include='*.ts' \
  --include='*.mjs' \
  2>/dev/null || true

printf '\n=== SERVER ROUTE REGISTRATION ===\n'
grep -RInE \
  'app\.(get|post|put|patch|delete|use)|router\.(get|post|put|patch|delete|use)' \
  server routes \
  --include='*.ts' \
  --include='*.mjs' \
  2>/dev/null || true

printf '\n=== MISSION CONTROL CLIENT FILES ===\n'
find client/src \
  -type f \
  \( -iname '*mission*' -o -iname '*dashboard*' -o -iname '*governance*' \) \
  | sort

printf '\n=== MISSION CONTROL STATE REFERENCES ===\n'
grep -RInE \
  'Mission Control|MissionDashboard|governance|package|delegation|validation|envelope|lifecycle|Infrastructure|Diagnostics' \
  client/src \
  --include='*.ts' \
  --include='*.tsx' \
  --include='*.css' \
  2>/dev/null || true

printf '\n=== CLIENT API MODULES ===\n'
find client/src \
  -type f \
  \( -iname '*api*.ts' -o -iname '*api*.tsx' \) \
  | sort

printf '\n=== CLIENT FETCH CALLS ===\n'
grep -RInE \
  'fetch\(|axios|/api/' \
  client/src \
  --include='*.ts' \
  --include='*.tsx' \
  2>/dev/null || true

printf '\n=== GOVERNANCE DATABASE COUNTS ===\n'
sqlite3 db/main.db "
SELECT 'governance_packages', COUNT(*) FROM governance_packages
UNION ALL
SELECT 'governance_delegations', COUNT(*) FROM governance_delegations
UNION ALL
SELECT 'governance_validation_results', COUNT(*) FROM governance_validation_results
UNION ALL
SELECT 'governance_envelope_gates', COUNT(*) FROM governance_envelope_gates
UNION ALL
SELECT 'governance_envelopes', COUNT(*) FROM governance_envelopes
UNION ALL
SELECT
  'governance_lifecycle_events',
  CASE
    WHEN EXISTS (
      SELECT 1
      FROM sqlite_master
      WHERE type='table'
        AND name='governance_lifecycle_events'
    )
    THEN (SELECT COUNT(*) FROM governance_lifecycle_events)
    ELSE 0
  END;
"

printf '\n=== REPOSITORY STATE ===\n'
git status --short
