#!/usr/bin/env bash
set -euo pipefail

cat <<'EOT'
PHASE 470.0 — CAPTURE CONSOLE NOW
=================================

YOU’RE IN — THIS IS THE MOMENT.

Do this immediately:

1. Make sure DevTools is open (it should already be open).
2. Click the "Console" tab.
3. Press:
   Command + Shift + R

4. Look for RED errors.

COPY EXACTLY:
- The FIRST red error
- And 2–3 lines after it (stack trace if present)

FORMAT:

[CONSOLE_ERRORS_START]
(paste here)
[CONSOLE_ERRORS_END]

DO NOT summarize.
DO NOT explain.

Paste raw.

This is now a surgical fix — one error → one solution.
EOT
