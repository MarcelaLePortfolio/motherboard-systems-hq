#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== RECONCILE CURRENT PROGRAM PRIORITY ==="
echo "CLOSED_MILESTONE=MISSION_CONTROL_PROJECT_CONTEXT_ALIGNMENT"
echo "FINAL_MILESTONE_DR=20260825_144359"
echo "EMPTY_PRESENTATION_FIX_CLOSURE_COMMIT=409f8ea1"
echo "SUCCESSOR_MILESTONE=NOT_YET_ESTABLISHED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

rg -n \
  'remaining capability|remaining gap|NEXT_MILESTONE|SUCCESSOR_MILESTONE|next canonical milestone|current program priority' \
  docs scripts \
  -g '*.md' -g '*.sh' \
  2>/dev/null || true

echo "NEXT_ACTION=CLASSIFY_CURRENT_EVIDENCE_SUPPORTED_SUCCESSOR_PRIORITY"
