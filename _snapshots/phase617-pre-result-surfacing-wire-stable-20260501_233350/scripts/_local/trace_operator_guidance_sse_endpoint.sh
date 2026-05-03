#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_489_H1_OPERATOR_GUIDANCE_SSE_TRACE_OUTPUT.txt"

{
  echo "PHASE 489 — H1 OPERATOR GUIDANCE SSE TRACE OUTPUT"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo

  echo "=== SERVED DASHBOARD SCRIPT TAG CHECK ==="
  curl -s http://localhost:8080 | grep -n 'operatorGuidance.sse.js' || echo "SCRIPT TAG NOT FOUND IN SERVED HTML"
  echo

  echo "=== LOCAL SSE CLIENT SOURCE ==="
  sed -n '1,220p' "$ROOT/public/js/operatorGuidance.sse.js" 2>/dev/null || echo "MISSING: public/js/operatorGuidance.sse.js"
  echo

  echo "=== SSE ENDPOINT HEADERS ==="
  curl -i -s http://localhost:8080/api/operator-guidance | sed -n '1,60p' || true
  echo

  echo "=== SSE ENDPOINT BODY SAMPLE (8s timeout) ==="
  timeout 8s curl -N -s http://localhost:8080/api/operator-guidance || true
  echo
  echo

  echo "=== SERVER-SIDE REFERENCES TO /api/operator-guidance ==="
  grep -RIn '/api/operator-guidance\|operator-guidance' "$ROOT" \
    --include="*.js" --include="*.ts" --include="*.tsx" --include="*.mjs" --include="*.cjs" --include="*.html" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build || true
  echo

  echo "=== LIKELY SERVER ROUTE / HANDLER FILES ==="
  grep -RIn 'EventSource\|text/event-stream\|res.write\|operatorGuidance\|operator-guidance' "$ROOT" \
    --include="*.js" --include="*.ts" --include="*.tsx" --include="*.mjs" --include="*.cjs" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build || true
  echo
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
