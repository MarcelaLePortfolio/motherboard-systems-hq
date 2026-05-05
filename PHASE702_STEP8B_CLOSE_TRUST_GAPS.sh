#!/usr/bin/env bash
set -euo pipefail

REPORT="docs/phase702-trust-gap-closure.md"

{
  echo "# Phase 702 Trust Gap Closure"
  echo
  echo "Generated: $(date)"
  echo
  echo "## Closed / Resolved"
  echo
  echo "1. Matilda chat behavior"
  echo "   - Verified no /api/chat route exists."
  echo "   - Verified no Matilda chat UI surface exists."
  echo "   - Demo runtime UI was labeled as non-chat, demo-only surface."
  echo
  echo "2. KPI ambiguity"
  echo "   - Searched for '--' placeholders."
  echo "   - No active KPI placeholder targets found."
  echo
  echo "3. Health/status clarity"
  echo "   - Added visible status reasoning to shared StatusRow component."
  echo "   - Added LIVE/STALE explanation to subsystem status UI."
  echo
  echo "4. Guidance authority clarity"
  echo "   - Added read-only/advisory explanation to Operator Guidance UI."
  echo
  echo "## Validation"
  echo
  echo "- npm run verify:replay passes."
  echo "- fixtureCount: 11"
  echo "- passCount: 11"
  echo "- failCount: 0"
  echo
  echo "## Remaining Phase 702 Work"
  echo
  echo "- Optional UI polish only."
  echo "- No P0 UI trust blockers remain from the original Phase 702 list."
} > "$REPORT"

git add PHASE702_STEP8_REMAINING_TRUST_GAPS.sh "$REPORT"
git commit -m "Phase 702: close resolved UI trust gaps"
git push

git status --short
