#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs

OUT="docs/phase464_x_operator_guidance_server_target_isolation.txt"

{
  echo "PHASE 464.X — OPERATOR GUIDANCE SERVER TARGET ISOLATION"
  echo "======================================================="
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo root: $(pwd)"
  echo

  echo "1) Exact path and symbol matches (bounded)"
  rg -n '/api/operator-guidance|operator-guidance|operatorGuidance|SYSTEM_HEALTH|deterministic-baseline|phase457-proof|Controlled execution path verified' . \
    --glob '!node_modules' --glob '!.git' | head -n 300 || true
  echo

  echo "2) Likely server entrypoints / routes"
  find . -type f \
    \( -iname 'server.*' -o -iname '*route*.*' -o -iname '*api*.*' -o -iname '*express*.*' -o -iname '*app*.*' -o -iname '*index*.*' \) \
    -not -path '*/node_modules/*' -not -path '*/.git/*' \
    | sort \
    | grep -E '\.(ts|tsx|js|mjs)$' \
    | head -n 200 || true
  echo

  echo "3) Route definitions mentioning guidance / SSE / health (bounded)"
  rg -n 'app\.get|router\.get|text/event-stream|res\.write|res\.end|setInterval|clearInterval|guidance|operator|health|SSE|EventSource' \
    server src app scripts . \
    --glob '!node_modules' --glob '!.git' 2>/dev/null | head -n 400 || true
  echo

  echo "4) Focused candidate files from exact path/symbol matches"
  for f in $(rg -l '/api/operator-guidance|operator-guidance|operatorGuidance|SYSTEM_HEALTH|deterministic-baseline|phase457-proof|Controlled execution path verified' . --glob '!node_modules' --glob '!.git' | head -n 20); do
    if [ -f "$f" ]; then
      echo
      echo "FILE: $f"
      echo "----------------------------------------"
      rg -n '/api/operator-guidance|operator-guidance|operatorGuidance|SYSTEM_HEALTH|deterministic-baseline|phase457-proof|Controlled execution path verified|text/event-stream|res\.write|res\.end|setInterval|clearInterval|guidance|message|meta' "$f" || true
      echo
      sed -n '1,260p' "$f"
      echo
    fi
  done

  echo "5) Ranked likely single-file mutation targets"
  rg -l '/api/operator-guidance|operator-guidance|operatorGuidance|SYSTEM_HEALTH|deterministic-baseline|phase457-proof|Controlled execution path verified|text/event-stream|res\.write|res\.end|setInterval' . \
    --glob '!node_modules' --glob '!.git' \
    | awk '
      {
        score=100
        if ($0 ~ /server|route|api|app|index/) score-=35
        if ($0 ~ /guidance|operator/) score-=30
        if ($0 ~ /public\//) score+=25
        if ($0 ~ /docs\//) score+=100
        if ($0 ~ /scripts\//) score+=40
        print score " " $0
      }
    ' | sort -n -k1,1 -k2,2 | awk '!seen[$2]++' | head -n 30
  echo

  echo "6) Decision gate"
  echo "- Choose the first non-doc, non-script file that both defines or feeds operator guidance and can be mutated alone."
  echo "- If only browser files appear, the route may be missing and guidance may still be static-client-owned."
} > "$OUT"

echo "Wrote $OUT"
