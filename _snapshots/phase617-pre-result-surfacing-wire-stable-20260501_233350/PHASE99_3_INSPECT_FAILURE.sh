#!/usr/bin/env bash
set -euo pipefail

echo "Phase 99.3 — failure inspection"
echo
echo "FILE: src/cognition/situationSummaryIntegration.smoke.ts"
echo "────────────────────────────────"
nl -ba src/cognition/situationSummaryIntegration.smoke.ts
echo
echo "FILE: src/cognition/situationSummaryComposer.ts"
echo "────────────────────────────────"
nl -ba src/cognition/situationSummaryComposer.ts
