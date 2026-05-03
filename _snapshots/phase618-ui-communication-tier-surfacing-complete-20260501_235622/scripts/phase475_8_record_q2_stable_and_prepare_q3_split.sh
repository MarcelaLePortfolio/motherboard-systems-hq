#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT_OUT="docs/phase475_8_q2_probe_result.txt"
NEXT_OUT="docs/phase475_8_prepare_q3_q4_split.txt"

mkdir -p docs

cat > "$RESULT_OUT" <<'EOT'
PHASE 475.8 — Q2 PROBE RESULT
=============================

RESULT:
Q2_PROBE_STABLE

OPTIONAL_NOTE:
The Q2 probe appears stable.
EOT

cat > "$NEXT_OUT" <<'EOT'
PHASE 475.8 — PREPARE NEXT SPLIT (Q3 / Q4)
==========================================

CRITICAL UPDATE
- Q1 is stable
- Q2 is stable

CONCLUSION
- The freeze is NOT in the top half of the dashboard body.
- The fault domain is now isolated to the BOTTOM HALF.

NEXT SAFE CORRIDOR
- Split the bottom half into two new probes:
  • Q3 (first half of bottom section)
  • Q4 (second half of bottom section)

DISCIPLINE
- Do NOT reintroduce JS
- Do NOT reintroduce CSS
- Continue pure markup isolation only

NEXT STEP
- Create Q3 and Q4 probe pages from bottom-half content
- Then test Q3 first
EOT

echo "Wrote $RESULT_OUT"
sed -n '1,120p' "$RESULT_OUT"
echo
echo "Wrote $NEXT_OUT"
sed -n '1,200p' "$NEXT_OUT"
