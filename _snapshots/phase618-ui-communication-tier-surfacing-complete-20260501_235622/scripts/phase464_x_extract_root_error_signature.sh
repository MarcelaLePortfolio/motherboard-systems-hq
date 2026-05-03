#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase464_x_root_error_signature.txt"

mkdir -p docs

echo "PHASE 464.X — ROOT ERROR SIGNATURE EXTRACTION" > "$OUT"
echo "=============================================" >> "$OUT"
echo >> "$OUT"

echo "STEP 1 — Capture last 300 lines of logs" >> "$OUT"
docker compose logs --tail=300 >> "$OUT" 2>&1 || echo "no logs available" >> "$OUT"
echo >> "$OUT"

echo "STEP 2 — Extract FIRST fatal error block" >> "$OUT"
docker compose logs 2>&1 | awk '
/Error|Cannot find module|Unhandled|Exception/ {
  print "---- ERROR BLOCK START ----"
  print
  capture=1
  next
}
capture && NF {
  print
  if (++lines > 20) {
    print "---- ERROR BLOCK END ----"
    exit
  }
}
' >> "$OUT" || echo "no structured error block found" >> "$OUT"
echo >> "$OUT"

echo "STEP 3 — Highlight missing dependency signals" >> "$OUT"
docker compose logs 2>&1 | rg -i "Cannot find module" >> "$OUT" || echo "no missing modules detected" >> "$OUT"
echo >> "$OUT"

echo "STEP 4 — Highlight crash loop indicators" >> "$OUT"
docker compose logs 2>&1 | rg -i "exit|crash|restart" >> "$OUT" || echo "no crash loop signals" >> "$OUT"
echo >> "$OUT"

echo "DIAGNOSIS TARGET:"
echo "- The FIRST error block above is the root cause."
echo "- Do NOT fix broadly. Only resolve that exact failure."
echo >> "$OUT"

echo "Wrote $OUT"

