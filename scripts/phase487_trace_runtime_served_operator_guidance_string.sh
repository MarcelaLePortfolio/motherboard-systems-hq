#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_runtime_served_operator_guidance_string_${STAMP}.txt"
TMP_FILES="$(mktemp)"

find . \
  \( -path "./.git" -o -path "./node_modules" -o -path "./coverage" \) -prune -o \
  \( -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.json" -o -name "*.html" -o -name "*.mjs" -o -name "*.cjs" \) \) -print 2>/dev/null | sort -u > "${TMP_FILES}"

redact_stream() {
  python3 -c 'import re,sys; s=sys.stdin.read(); s=re.sub(r"sk-[A-Za-z0-9_-]{20,}", "[REDACTED_OPENAI_API_KEY]", s); print(s, end="")'
}

{
  echo "PHASE 487 — TRACE RUNTIME-SERVED OPERATOR GUIDANCE STRING"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== EXACT STRING HITS: AWAITING / LIVE / CONFIDENCE / SOURCE ==="
  xargs rg -n -C 6 "Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Confidence: insufficient|Sources: diagnostics/system-health" < "${TMP_FILES}" 2>/dev/null | redact_stream || true
  echo

  echo "=== BUILT ARTIFACT HITS (.next / dist / dashboard build outputs) ==="
  find . \
    \( -path "./.next" -o -path "./dist" -o -path "./dashboard/.next" -o -path "./dashboard/dist" -o -path "./dashboard/build" \) \
    -type f 2>/dev/null \
    | sort -u \
    | while IFS= read -r file; do
        rg -n -C 3 "Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Confidence: insufficient|Sources: diagnostics/system-health" "${file}" 2>/dev/null || true
      done | redact_stream
  echo

  echo "=== PM2 PROCESS COMMANDS ==="
  pm2 jlist 2>/dev/null | redact_stream || true
  echo

  echo "=== PORT OWNERS ==="
  lsof -nP -iTCP:3000 -sTCP:LISTEN || true
  lsof -nP -iTCP:8080 -sTCP:LISTEN || true
  echo

  echo "=== HTTP BODY TRACE (first 220 lines) ==="
  curl -s http://localhost:8080 | sed -n '1,220p' | redact_stream || true
  echo

  echo "=== NEXT ACTION ==="
  echo "Patch the file or built artifact that contains the exact visible strings above."
  echo "If only built artifacts match, rebuild or restart the actual serving app, not just PM2 agents."
  echo
} > "${OUT}"

rm -f "${TMP_FILES}"

echo "${OUT}"
