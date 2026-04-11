#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT="${1:-STRUCTURE_RESTORED_BUT_BROKEN}"
NOTE="${2:-Please replace this note with what still looks wrong, if needed.}"
RESULT_OUT="docs/phase478_0_restored_structure_result.txt"
NEXT_OUT="docs/phase478_0_next_step_after_restored_structure_observation.txt"

case "$RESULT" in
  STRUCTURE_RESTORED_CORRECT|STRUCTURE_RESTORED_BUT_BROKEN|WHITE_SCREEN_RETURNED)
    ;;
  *)
    echo "Invalid result: $RESULT"
    exit 1
    ;;
esac

mkdir -p docs

cat > "$RESULT_OUT" <<EOT
PHASE 478.0 — RESTORED STRUCTURE RESULT
=======================================

RESULT:
$RESULT

OPTIONAL_NOTE:
$NOTE
EOT

cat > "$NEXT_OUT" <<'EOT'
PHASE 478.0 — NEXT STEP AFTER RESTORED STRUCTURE OBSERVATION
============================================================

INTERPRETATION
- If the dashboard is stable but still structurally wrong, the remaining problem is not the broad page skeleton.
- The remaining problem is now most likely:
  • missing CSS-dependent behavior or layout assumptions
  • missing JS-driven DOM population
  • or specific script-driven class/state application

NEXT SAFE CORRIDOR
- Reintroduce scripts one at a time, in controlled order
- Start with the smallest, least risky script first
- Observe after each single reintroduction
- Do NOT restore multiple scripts at once
- Do NOT restore bundle.js yet

RECOMMENDED FIRST SCRIPT
- js/phase60_live_clock.js

RATIONALE
- It is likely lower-risk than workspace/history wiring
- It should help verify whether small live behavior can return without destabilizing the page
EOT

echo "Wrote $RESULT_OUT"
sed -n '1,120p' "$RESULT_OUT"
echo
echo "Wrote $NEXT_OUT"
sed -n '1,220p' "$NEXT_OUT"
