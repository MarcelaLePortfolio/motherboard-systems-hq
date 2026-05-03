#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs

OUT="docs/phase464_x_exact_guidance_producer_hunt_repaired.txt"

{
  echo "PHASE 464.X — EXACT GUIDANCE PRODUCER HUNT (REPAIRED)"
  echo "====================================================="
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo root: $(pwd)"
  echo

  echo "1) Browser consumer exact endpoint references"
  rg -n 'EventSource\(|fetch\(|XMLHttpRequest|/api/operator-guidance|operator-guidance' public bundle.js \
    --glob '!node_modules' --glob '!.git' 2>/dev/null | head -n 300 || true
  echo

  echo "2) Exact repo matches for endpoint/path strings"
  rg -n '/api/operator-guidance|operator-guidance|operatorGuidance' . \
    --glob '!node_modules' --glob '!.git' 2>/dev/null | head -n 300 || true
  echo

  echo "3) Server entrypoint candidates"
  find . -type f \
    \( -iname 'server.*' -o -iname 'index.*' -o -iname 'app.*' -o -iname '*route*.*' -o -iname '*api*.*' -o -iname '*express*.*' -o -iname '*.mjs' \) \
    -not -path '*/node_modules/*' -not -path '*/.git/*' \
    | sort | head -n 200
  echo

  echo "4) Focused route/producer excerpts (bounded)"
  find . -type f \
    \( -iname 'server.*' -o -iname 'index.*' -o -iname 'app.*' -o -iname '*route*.*' -o -iname '*api*.*' -o -iname '*express*.*' -o -iname '*.mjs' \) \
    -not -path '*/node_modules/*' -not -path '*/.git/*' \
    | while read -r f; do
        if rg -q 'app\.get|app\.use|router\.get|router\.use|createServer|http\.createServer|text/event-stream|res\.write|res\.end|setInterval|clearInterval|SYSTEM_HEALTH|guidance|operator' "$f" 2>/dev/null; then
          echo
          echo "FILE: $f"
          echo "----------------------------------------"
          rg -n 'app\.get|app\.use|router\.get|router\.use|createServer|http\.createServer|text/event-stream|res\.write|res\.end|setInterval|clearInterval|SYSTEM_HEALTH|guidance|operator' "$f" 2>/dev/null | head -n 120 || true
          echo
          sed -n '1,220p' "$f"
          echo
        fi
      done || true
  echo

  echo "5) Fallback/static producer strings"
  rg -n 'SYSTEM_HEALTH|deterministic-baseline|phase457-proof|Controlled execution path verified|Deterministic guidance pipeline executed successfully|Awaiting bounded guidance stream' . \
    --glob '!node_modules' --glob '!.git' 2>/dev/null | head -n 300 || true
  echo

  echo "6) Ranked likely single-file targets"
  rg -l '/api/operator-guidance|operator-guidance|operatorGuidance|text/event-stream|res\.write|SYSTEM_HEALTH|deterministic-baseline|phase457-proof|guidance' . \
    --glob '!node_modules' --glob '!.git' 2>/dev/null \
    | while read -r f; do
        score=100
        case "$f" in
          *server*|*index*|*app*|*route*|*api*|*.mjs) score=$((score-35));;
        esac
        case "$f" in
          *public/js/operatorGuidance*) score=$((score-20));;
        esac
        case "$f" in
          *dashboard-status*|*ops-sse-listener*|*ops-globals-bridge*) score=$((score-10));;
        esac
        case "$f" in
          docs/*) score=$((score+100));;
        esac
        case "$f" in
          scripts/*) score=$((score+50));;
        esac
        printf "%03d %s\n" "$score" "$f"
      done | sort -n -k1,1 -k2,2 | awk '!seen[$2]++' | head -n 40
  echo

  echo "7) Decision gate"
  echo "- If exact route exists, mutate only that producer file next."
  echo "- If no route exists, identify what endpoint /api/operator-guidance resolves to in the server entrypoint."
  echo "- If only static/browser files remain, pivot back to exact client payload source with the repaired ranked list."
} > "$OUT"

echo "Wrote $OUT"
