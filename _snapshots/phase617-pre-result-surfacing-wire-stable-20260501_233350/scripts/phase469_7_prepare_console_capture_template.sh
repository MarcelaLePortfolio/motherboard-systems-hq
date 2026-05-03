#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase469_7_console_capture_template.txt"

mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 469.7 — CONSOLE CAPTURE TEMPLATE
=====================================

PASTE YOUR BROWSER CONSOLE OUTPUT BELOW
---------------------------------------

[CONSOLE_ERRORS_START]

(Paste ALL red errors here)

[CONSOLE_ERRORS_END]


OPTIONAL — NETWORK FAILURE (FIRST FAILED REQUEST)
------------------------------------------------

[NETWORK_ERROR_START]

(Paste first failed request details if any)

[NETWORK_ERROR_END]


NOTES (OPTIONAL)
----------------
- What you see visually (white screen, partial render, etc.)
- Any flicker or loading behavior


IMPORTANT
---------
Do NOT summarize.
Do NOT filter.
Paste raw output exactly.

RETURN THIS FILE CONTENT TO CHATGPT.
EOT

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"
