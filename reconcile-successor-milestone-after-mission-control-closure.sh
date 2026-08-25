#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== RECONCILE SUCCESSOR MILESTONE ==="
echo "CLOSED_MILESTONE=MISSION_CONTROL_PROJECT_CONTEXT_ALIGNMENT"
echo "MILESTONE_CLOSURE_COMMIT=5191d545"
echo "FINAL_DR=20260825_144359"
echo "FINAL_DR_COMMIT=2e204db4"
echo "SUCCESSOR_MILESTONE=NOT_YET_ESTABLISHED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

rg -n \
  'NEXT_MILESTONE|SUCCESSOR_MILESTONE|successor milestone|next canonical milestone' \
  docs scripts \
  -g '*.md' -g '*.sh' \
  2>/dev/null || true

echo "NEXT_ACTION=CLASSIFY_SUCCESSOR_MILESTONE_FROM_CANONICAL_EVIDENCE_ONLY"
