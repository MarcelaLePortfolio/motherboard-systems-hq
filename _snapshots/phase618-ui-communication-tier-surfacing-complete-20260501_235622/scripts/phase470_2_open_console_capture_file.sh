#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

FILE="docs/phase470_1_console_errors_capture.txt"

if command -v code >/dev/null 2>&1; then
  code "$FILE"
else
  open -a TextEdit "$FILE"
fi

echo "Paste the first red console error into:"
echo "$FILE"
