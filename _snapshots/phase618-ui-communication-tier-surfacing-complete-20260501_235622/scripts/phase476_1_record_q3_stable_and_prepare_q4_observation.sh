#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT_OUT="docs/phase476_1_q3_probe_result.txt"
NEXT_OUT="docs/phase476_1_prepare_q4_observation.txt"

mkdir -p docs

cat > "$RESULT_OUT" <<'EOT'
PHASE 476.1 — Q3 PROBE RESULT
=============================

RESULT:
Q3_PROBE_STABLE

OPTIONAL_NOTE:
The Q3 probe appears stable.
EOT

cat > "$NEXT_OUT" <<'EOT'
PHASE 476.1 — PREPARE Q4 OBSERVATION
====================================

CRITICAL UPDATE
- Q1 is stable
- Q2 is stable
- Q3 is stable

CONCLUSION
- The freeze is NOT in Q1, Q2, or Q3.
- The fault domain is now isolated to Q4.

DO THIS NOW
1. Open:
   http://localhost:8080/dashboard_body_q4_probe.html

2. Let it sit for 30–60 seconds.

3. Try:
   - scroll once
   - click once anywhere harmless

RETURN TO CHATGPT WITH EXACTLY ONE OF THESE
- Q4_PROBE_STABLE
- Q4_PROBE_STILL_UNRESPONSIVE
- WHITE_SCREEN_RETURNED
EOT

echo "Wrote $RESULT_OUT"
sed -n '1,120p' "$RESULT_OUT"
echo
echo "Wrote $NEXT_OUT"
sed -n '1,200p' "$NEXT_OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard_body_q4_probe.html" || true
fi
