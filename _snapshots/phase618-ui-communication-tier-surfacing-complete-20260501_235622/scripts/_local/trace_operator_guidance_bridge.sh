#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_489_H1_OPERATOR_GUIDANCE_TRACE_OUTPUT.txt"

{
  echo "PHASE 489 — H1 OPERATOR GUIDANCE TRACE OUTPUT"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo

  echo "=== LOCAL DASHBOARD BRIDGE FILE PRESENCE ==="
  ls -l "$ROOT"/docs/dashboard_bridge_latest.json 2>/dev/null || echo "MISSING: docs/dashboard_bridge_latest.json"
  echo

  echo "=== LOCAL DASHBOARD BRIDGE CONTENT (FIRST 200 LINES) ==="
  sed -n '1,200p' "$ROOT"/docs/dashboard_bridge_latest.json 2>/dev/null || echo "UNREADABLE OR MISSING LOCAL BRIDGE FILE"
  echo

  echo "=== SERVED DASHBOARD BRIDGE HTTP HEADERS ==="
  curl -i -s http://localhost:8080/docs/dashboard_bridge_latest.json | sed -n '1,40p' || true
  echo

  echo "=== SERVED DASHBOARD BRIDGE BODY (FIRST 120 LINES) ==="
  curl -s http://localhost:8080/docs/dashboard_bridge_latest.json | sed -n '1,120p' || true
  echo

  echo "=== CONFIDENCE FIELD SEARCH IN LOCAL BRIDGE ==="
  grep -nEi 'confidence|uiSummary|headline|approval|governance|execution' "$ROOT"/docs/dashboard_bridge_latest.json 2>/dev/null || echo "NO MATCHES IN LOCAL BRIDGE"
  echo

  echo "=== CONFIDENCE FIELD SEARCH IN SERVED BRIDGE ==="
  curl -s http://localhost:8080/docs/dashboard_bridge_latest.json | grep -nEi 'confidence|uiSummary|headline|approval|governance|execution' || echo "NO MATCHES IN SERVED BRIDGE"
  echo

  echo "=== CURRENT INDEX OPERATOR GUIDANCE SCRIPT BLOCK ==="
  grep -nA40 -B10 'phase489-h1-operator-guidance-rewire' "$ROOT/public/index.html" || echo "REWIRE SCRIPT BLOCK NOT FOUND"
  echo

  echo "=== CURRENT INDEX OPERATOR GUIDANCE DOM ANCHORS ==="
  grep -nA20 -B10 'operator-guidance-panel\|operator-guidance-response\|operator-guidance-meta' "$ROOT/public/index.html" || echo "GUIDANCE DOM ANCHORS NOT FOUND"
  echo

  echo "=== LIKELY EXISTING GUIDANCE SCRIPTS / SOURCES ==="
  grep -RInE 'operator-guidance|guidance-response|confidence: insufficient|dashboard_bridge_latest|dashboard_bridge|uiSummary|latestGovernance|latestApproval|latestExecution' \
    "$ROOT" \
    --include="*.js" --include="*.ts" --include="*.tsx" --include="*.html" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build || true
  echo
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
