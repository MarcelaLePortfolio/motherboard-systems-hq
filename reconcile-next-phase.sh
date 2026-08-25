#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== RECONCILE NEXT PHASE ==="
echo "CLOSED_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "PHASE_CLOSURE_COMMIT=18de0d2a"
echo "POST_PHASE_DR=20260825_143436"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== SUCCESSOR EVIDENCE ==="
rg -n \
  'NEXT_PHASE|NEXT_MILESTONE|successor phase|successor milestone|MISSION_CONTROL_PROJECT_CONTEXT_ALIGNMENT' \
  . \
  -g '*.md' -g '*.txt' -g '*.sh' \
  -g '!node_modules/**' -g '!.git/**' \
  2>/dev/null || true

echo
echo "NEXT_ACTION=CLASSIFY_SUCCESSOR_FROM_CANONICAL_EVIDENCE_ONLY"
