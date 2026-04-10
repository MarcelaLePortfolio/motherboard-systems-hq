#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase469_6_browser_console_capture_next.txt"

mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 469.6 — BROWSER CONSOLE CAPTURE NEXT
==========================================

STATUS CONFIRMED
- Server path is clean on host port 8080.
- dashboard.html returns 200.
- bundle.js returns 200.
- /api/tasks returns 200.

NEXT REQUIRED EVIDENCE
- Browser-side console/runtime failure during dashboard boot.

DO THIS EXACTLY
1. Open:
   http://localhost:8080/dashboard.html

2. Open DevTools:
   Chrome/Edge: Command + Option + J
   Or: View -> Developer -> JavaScript Console

3. With DevTools open, hard refresh:
   Command + Shift + R

4. Copy ALL red errors from:
   - Console
   - And if present, the first failed request from Network

PRIORITY SIGNALS TO LOOK FOR
- Uncaught TypeError
- ReferenceError
- SyntaxError / Unexpected token
- Failed to fetch
- EventSource errors
- Module load errors
- MIME type errors

OPTIONAL NETWORK FILTERS
- bundle.js
- dashboard.html
- api/tasks
- api/operator-guidance
- events/ops

RETURN TO CHATGPT WITH
- The red console errors
- The first failed network request details, if any
- A screenshot only if copying text is annoying

DECISION TARGET
- Next corridor is browser boot failure isolation, not server repair.
EOT

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"
