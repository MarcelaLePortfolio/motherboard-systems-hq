#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase464_x_root_error_signature.txt"

mkdir -p docs

echo "PHASE 464.X — ROOT ERROR (HUMAN-READABLE)" > "$OUT"
echo "=========================================" >> "$OUT"
echo >> "$OUT"

ERROR_BLOCK=$(docker compose logs 2>&1 | awk '
/Error|Cannot find module|Unhandled|Exception/ {
  print "---- ERROR BLOCK START ----"
  print
  capture=1
  next
}
capture && NF {
  print
  if (++lines > 25) {
    print "---- ERROR BLOCK END ----"
    exit
  }
}
')

if [ -z "$ERROR_BLOCK" ]; then
  ERROR_BLOCK="NO CLEAR ERROR BLOCK FOUND — CHECK FULL LOG FILE"
fi

echo "$ERROR_BLOCK" >> "$OUT"

echo >> "$OUT"
echo "NEXT ACTION REQUIRED:" >> "$OUT"
echo "- Read the error block above." >> "$OUT"
echo "- Identify EXACT missing module / crash point." >> "$OUT"
echo "- Fix ONLY that dependency or import." >> "$OUT"

echo "Wrote $OUT"
echo
echo "================ ROOT ERROR ================"
echo "$ERROR_BLOCK"
echo "==========================================="

