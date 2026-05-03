#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT_OUT="docs/phase478_3_phase60_result.txt"
NEXT_OUT="docs/phase478_3_next_corridor_after_phase60_result.txt"

mkdir -p docs

cat > "$RESULT_OUT" <<'EOT'
PHASE 478.3 — PHASE60 LIVE CLOCK RESULT
=======================================

RESULT:
PHASE60_SCRIPT_STABLE

OPTIONAL_NOTE:
The page remains stable, but the layout is still not right.
EOT

cat > "$NEXT_OUT" <<'EOT'
PHASE 478.3 — NEXT CORRIDOR AFTER PHASE60 RESULT
================================================

CRITICAL UPDATE
- Original structural layout is restored
- Dashboard remains stable with js/phase60_live_clock.js reintroduced
- Layout is still incorrect

INTERPRETATION
- phase60_live_clock.js is not the source of the structural/layout defect
- The remaining issue is more likely tied to missing stylesheet behavior than to this small live-clock script
- Next safest corridor is CSS reintroduction before adding more JS complexity

NEXT SAFE CORRIDOR
- Reintroduce local CSS one file at a time
- Do NOT restore bundle.js yet
- Do NOT restore multiple CSS files at once
- Do NOT stack CSS and JS changes in one step

RECOMMENDED FIRST CSS FILE
- css/dashboard.css?v=darkmode

RATIONALE
- This is the highest-probability base layout stylesheet
- It is more likely than the live-clock script to restore missing sizing, placement, and visual structure
EOT

echo "Wrote $RESULT_OUT"
sed -n '1,120p' "$RESULT_OUT"
echo
echo "Wrote $NEXT_OUT"
sed -n '1,220p' "$NEXT_OUT"
