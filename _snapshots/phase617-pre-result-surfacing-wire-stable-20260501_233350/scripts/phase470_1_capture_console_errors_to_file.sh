#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase470_1_console_errors_capture.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 470.1 — CONSOLE ERRORS CAPTURE
====================================

Paste the first red console error below, plus 2–3 lines after it.

[CONSOLE_ERRORS_START]

(paste here)

[CONSOLE_ERRORS_END]
EOT

echo "Wrote $OUT"
sed -n '1,120p' "$OUT"
