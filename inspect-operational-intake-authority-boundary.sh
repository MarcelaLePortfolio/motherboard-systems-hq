#!/usr/bin/env bash
set -euo pipefail

echo "=== CORRIDOR 1 — OPERATIONAL INTAKE AUTHORITY BOUNDARY ==="

echo
echo "=== OPERATIONAL INTAKE ACTIVE SOURCE ==="
sed -n '1,700p' db/operational-intake-runtime.ts

echo
echo "=== OPERATIONAL INTAKE TEST ==="
sed -n '1,680p' db/operational-intake-runtime.test.ts

echo
echo "=== PRODUCTION LIFECYCLE CONSUMER ==="
sed -n '1,300p' server/lifecycle/production-lifecycle-consumer.ts

echo
echo "=== PRODUCTION OPERATIONAL CONSUMER ==="
sed -n '1,240p' server/operational/production-operational-consumer.ts

echo
echo "=== CANONICAL VS LEGACY PACKAGE LINEAGE ==="
rg -n \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  'matilda_canonical_packages|governance_packages|package_id|package_version|delegation_id|envelope_id|operational_intake_records' \
  db/matilda-canonical-package-runtime.ts \
  db/operational-intake-runtime.ts \
  db/operational-intake-runtime.test.ts \
  server/lifecycle/production-lifecycle-consumer.ts \
  server/operational/production-operational-consumer.ts \
  drizzle/0004_governance_lifecycle_artifacts.sql \
  drizzle/0005_operational_intake_artifacts.sql \
  2>/dev/null

echo
echo "=== EXISTING LINEAGE RECONCILIATION EVIDENCE ==="
rg -n \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  'canonical.*governance_packages|governance_packages.*canonical|matilda_canonical_packages.*governance|governance.*matilda_canonical_packages|operational.intake.*lineage|lineage.*operational.intake|legacy.*package|mixed.*root|canonical.*lineage' \
  db server routes scripts docs architecture drizzle \
  2>/dev/null | head -n 600

echo
echo "=== LIVE DATABASE LINEAGE ==="
if command -v sqlite3 >/dev/null 2>&1 && [[ -f db/main.db ]]; then
  sqlite3 -header -column db/main.db \
    "SELECT package_id, package_version, project_id FROM matilda_canonical_packages ORDER BY rowid DESC LIMIT 20;" \
    2>/dev/null || true

  sqlite3 -header -column db/main.db \
    "SELECT package_id, package_version, project_id FROM governance_packages ORDER BY rowid DESC LIMIT 20;" \
    2>/dev/null || true

  sqlite3 -header -column db/main.db \
    "SELECT delegation_id, package_id, package_version, authorization_state FROM governance_delegations ORDER BY rowid DESC LIMIT 20;" \
    2>/dev/null || true

  sqlite3 -header -column db/main.db \
    "SELECT envelope_id, package_id, package_version, delegation_id, lifecycle_state FROM governance_envelopes ORDER BY rowid DESC LIMIT 20;" \
    2>/dev/null || true

  sqlite3 -header -column db/main.db \
    "SELECT intake_id, envelope_id, package_id, package_version, delegation_id, lifecycle_state_at_intake, assigned_department, intake_status FROM operational_intake_records ORDER BY rowid DESC LIMIT 20;" \
    2>/dev/null || true
fi

echo
echo "=== INSPECTION COMPLETE ==="
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
