#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'CORRIDOR=PIPELINE_POSITION'

printf '\n=== OPERATIONAL INTAKE SCHEMA ===\n'
sqlite3 db/main.db ".schema operational_intake_records"

printf '\n=== LIVE AUTHORITATIVE PIPELINE EVIDENCE ===\n'
sqlite3 -header -column db/main.db "
SELECT
  p.package_id,
  p.requested_outcome,
  d.authorization_state AS delegation_state,
  e.lifecycle_state,
  oi.lifecycle_state_at_intake,
  oi.assigned_department
FROM governance_packages p
LEFT JOIN governance_delegations d
  ON d.package_id = p.package_id
 AND d.package_version = p.package_version
LEFT JOIN governance_envelopes e
  ON e.package_id = p.package_id
 AND e.package_version = p.package_version
LEFT JOIN operational_intake_records oi
  ON oi.envelope_id = e.envelope_id
ORDER BY p.created_at DESC
LIMIT 10;
"

printf '\n=== PIPELINE OWNERSHIP CONTRACT ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'operational_intake_records|assigned_department|Mission Pipeline|organizational movement|active responsibility' \
  db server routes docs 2>/dev/null | head -220

printf '\n=== UNTRACKED WORKTREE CHECK ===\n'
git status --short
