#!/usr/bin/env bash
set -euo pipefail

echo "=== DELEGATION ROOT RECONCILIATION ==="
sed -n '1,320p' docs/governance/PRODUCTION_DELEGATION_PACKAGE_ROOT_RECONCILIATION_CLOSURE_2026-08-23.md

echo
echo "=== PRIOR PACKAGE-LINEAGE FINDINGS ==="
for f in \
  docs/checkpoints/GOVERNANCE_RUNTIME_ACTIVATION_CORRIDOR_1_FINDINGS.md \
  docs/checkpoints/PROJECT_SCOPED_MISSION_CONTROL_CORRIDOR_2_COMPLETE.md \
  docs/checkpoints/PROJECT_SCOPED_MISSION_CONTROL_CORRIDOR_3_INVESTIGATION_DR.md \
  docs/governance-runtime-integration-readiness-scope-map.md; do
  echo "--- $f ---"
  sed -n '1,320p' "$f"
done

echo
echo "=== ACTIVE DELEGATION IMPLEMENTATION ==="
rg -n -C 8 \
  'matilda_canonical_packages|governance_packages|package_id|package_version|delegation' \
  db server routes \
  --glob '*delegation*' \
  --glob '!*.test.ts' \
  2>/dev/null | head -n 500

echo
echo "=== DOWNSTREAM GOVERNANCE PACKAGE ROOTS ==="
rg -n -C 5 \
  'REFERENCES governance_packages|REFERENCES matilda_canonical_packages|FROM governance_packages|FROM matilda_canonical_packages|JOIN governance_packages|JOIN matilda_canonical_packages' \
  db server routes drizzle \
  --glob '!*.test.ts' \
  2>/dev/null | head -n 600

echo
echo "=== VALIDATION / GATE / ENVELOPE CREATION PATHS ==="
rg -n -C 8 \
  'create.*Validation|create.*Envelope|validation_result|envelope_gate|governance_validation_results|governance_envelope_gates|governance_envelopes' \
  db server routes \
  --glob '!*.test.ts' \
  2>/dev/null | head -n 700

echo
echo "=== EXISTING MIGRATION OR RECONCILIATION INTENT ==="
rg -n \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  'Validation.*canonical.*Package|Envelope.*canonical.*Package|canonical.*Validation|canonical.*Envelope|downstream.*lineage|lineage.*downstream|package root reconciliation|Package Root Reconciliation' \
  docs scripts db server routes \
  2>/dev/null | head -n 700

echo
echo "=== INSPECTION COMPLETE ==="
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
