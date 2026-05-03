#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT_OUT="docs/phase475_6_q1_probe_result.txt"
NEXT_OUT="docs/phase475_6_prepare_q2_observation.txt"

mkdir -p docs

cat > "$RESULT_OUT" <<'EOT'
PHASE 475.6 — Q1 PROBE RESULT
=============================

RESULT:
Q1_PROBE_STABLE

OPTIONAL_NOTE:
The Q1 probe appears stable.
EOT

cat > "$NEXT_OUT" <<'EOT'
PHASE 475.6 — PREPARE Q2 OBSERVATION
====================================

CONCLUSION
- Q1 is stable.
- The failing markup is therefore more likely inside Q2, not Q1.

DO THIS NOW
1. Open:
   http://localhost:8080/dashboard_body_q2_probe.html

2. Let it sit for 30–60 seconds.

3. Try:
   - scroll once
   - click once anywhere harmless

RETURN TO CHATGPT WITH EXACTLY ONE OF THESE
- Q2_PROBE_STABLE
- Q2_PROBE_STILL_UNRESPONSIVE
- WHITE_SCREEN_RETURNED
EOT

echo "Wrote $RESULT_OUT"
sed -n '1,120p' "$RESULT_OUT"
echo
echo "Wrote $NEXT_OUT"
sed -n '1,200p' "$NEXT_OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard_body_q2_probe.html" || true
fi
