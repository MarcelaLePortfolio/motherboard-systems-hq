#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT_OUT="docs/phase476_2_q4_probe_result.txt"
VERDICT_OUT="docs/phase476_2_markup_isolation_verdict.txt"

mkdir -p docs

cat > "$RESULT_OUT" <<'EOT'
PHASE 476.2 — Q4 PROBE RESULT
=============================

RESULT:
Q4_PROBE_STABLE

OPTIONAL_NOTE:
The Q4 probe appears stable.
EOT

cat > "$VERDICT_OUT" <<'EOT'
PHASE 476.2 — MARKUP ISOLATION VERDICT
======================================

CRITICAL UPDATE
- Q1 is stable
- Q2 is stable
- Q3 is stable
- Q4 is stable

CONCLUSION
- The freeze does NOT reproduce in the isolated quarter probes.
- The fault is therefore NOT caused by a simple single quarter of raw dashboard body markup alone.
- The highest-confidence remaining fault domain is interaction between markup blocks, document shape outside the isolated probes, or structural corruption introduced by recombining sections into the full dashboard page.

CURRENT HIGHEST-CONFIDENCE VERDICT
- Server delivery is working.
- Container/public sync is working.
- Minimal probe is stable.
- Separate body probe is stable.
- Top-half probes are stable when isolated by quarters.
- Bottom-half probes are stable when isolated by quarters.
- The freeze likely depends on recomposed full-page structure, cross-section interaction, or broken document composition in the restored dashboard route.

NEXT SAFE CORRIDOR
- Compare full restored dashboard.html against the stable probe construction path.
- Isolate recomposition boundaries instead of continuing simple quarter splits.
- Do NOT re-enable bundle.js yet.
- Do NOT reintroduce local CSS yet.
- Next mutation should build a recomposed half+half probe or route-accurate shell from known-stable fragments.
EOT

echo "Wrote $RESULT_OUT"
sed -n '1,120p' "$RESULT_OUT"
echo
echo "Wrote $VERDICT_OUT"
sed -n '1,220p' "$VERDICT_OUT"
