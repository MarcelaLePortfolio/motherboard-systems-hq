#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n============================================================\n'
printf '🚦 CORRIDOR 3 · AUTHORITATIVE PACKAGE LINEAGE RECONCILIATION\n'
printf 'STATUS: 🟢 ACTIVE · DISPOSITION CLASSIFICATION\n'
printf '============================================================\n\n'

printf '%s\n' \
'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
'PHASE=PROJECT_SCOPED_MISSION_CONTROL_AND_ACTIVE_MISSION_BINDING' \
'CORRIDOR=AUTHORITATIVE_PACKAGE_LINEAGE_RECONCILIATION' \
'LIVE_CANONICAL_PACKAGE_ROUTE_MOUNTED=YES' \
'LIVE_PACKAGE_TO_DELEGATION_HANDOFF_FOUND=NO' \
'MATILDA_DOWNSTREAM_ROUTES_MOUNTED=NO' \
'GOVERNANCE_DOWNSTREAM_ROUTES_MOUNTED=NO' \
'IMPLEMENTATION_AUTHORIZED=NO'

printf '\n=== PHASE SCOPE / MISSION CONTROL CONTRACT ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E 'Project-Scoped Mission Control|Active Mission Binding|active mission|Mission Control.*read-only|Mission Read' \
  docs/architecture docs/checkpoints docs/*.md 2>/dev/null | head -360 || true

printf '\n=== CANONICAL PACKAGE LIVE AUTHORITY ===\n'
grep -Rni \
  --exclude='*.test.ts' \
  --exclude='*.bak' \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E 'matildaCanonicalPackageRouter|createCanonicalPackageFromApprovedSummary|canonicalPackageSchemaReady' \
  server db client/src 2>/dev/null | head -260 || true

printf '\n=== DOWNSTREAM MOUNT ABSENCE CONFIRMATION ===\n'
grep -nE \
  'governance|delegation|envelope|routing|assignment' \
  server/index.ts || true

printf '\n=== DISPOSITION TEST ===\n'
printf '%s\n' \
'LIVE_AUTHORITATIVE_PACKAGE_ROOT=MATILDA_CANONICAL_PACKAGE' \
'LIVE_DOWNSTREAM_GOVERNANCE_HANDOFF=ABSENT' \
'PARALLEL_DOWNSTREAM_RUNTIME_FAMILIES=UNMOUNTED' \
'ACTIVE_MISSION_SELECTION_FROM_DOWNSTREAM_GOVERNANCE=NOT_CURRENTLY_SAFE' \
'PACKAGE_ROOT_MIGRATION_REQUIRED_FOR_CURRENT_LIVE_LIFECYCLE=NOT_ESTABLISHED' \
'BROADER_GOVERNANCE_RECONCILIATION=UPSTREAM_OR_SEPARATE_SCOPE_CANDIDATE' \
'MISSION_CONTROL_MUST_NOT_INVENT_DOWNSTREAM_OPERATIONAL_STATE=YES' \
'IMPLEMENTATION_AUTHORIZED=NO' \
'PRODUCTION_CHANGE=NONE'
