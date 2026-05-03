#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT_OUT="docs/phase475_2_body_probe_result.txt"
VERDICT_OUT="docs/phase475_2_body_probe_verdict.txt"

mkdir -p docs

cat > "$RESULT_OUT" <<'EOT'
PHASE 475.2 — BODY PROBE RESULT
===============================

RESULT:
BODY_PROBE_STABLE

OPTIONAL_NOTE:
The separate body isolation probe appears stable.
EOT

cat > "$VERDICT_OUT" <<'EOT'
PHASE 475.2 — BODY PROBE VERDICT
================================

CONCLUSION
- The separate body probe is stable.
- The browser freeze is therefore NOT a broad browser/render-path failure.
- The freeze is specific to dashboard page structure/content, not the mere act of serving an HTML page on this route.

CURRENT HIGHEST-CONFIDENCE VERDICT
- Server delivery is working.
- Container/public sync is working.
- Minimal probe page is stable.
- Separate body isolation probe is stable.
- Dashboard body/content shape remains the likely fault domain.

NEXT SAFE CORRIDOR
- Restore dashboard route integrity.
- Isolate dashboard body sections by halves or major blocks.
- Do NOT re-enable bundle.js yet.
- Do NOT stack JavaScript reintroduction with markup isolation.
EOT

echo "Wrote $RESULT_OUT"
sed -n '1,120p' "$RESULT_OUT"
echo
echo "Wrote $VERDICT_OUT"
sed -n '1,200p' "$VERDICT_OUT"
