#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST="$(ls -t docs/phase487_visible_confidence_render_expression_*.txt 2>/dev/null | head -n 1 || true)"
if [ -z "${LATEST}" ]; then
  echo "No visible confidence render expression artifact found."
  exit 1
fi

OUT="docs/phase487_console_render_expression_verdict_$(date +%Y%m%d_%H%M%S).txt"

{
  echo "PHASE 487 — CONSOLE RENDER EXPRESSION VERDICT"
  echo "source_file=${LATEST}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== TARGET FILE ==="
  awk '/=== TARGET FILE ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | sed '/^[[:space:]]*$/d'
  echo

  echo "=== HIGH-SIGNAL LINES ==="
  awk '/=== HIGH-SIGNAL LINES FROM CONTEXT DOC ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | sed '/^[[:space:]]*$/d' | head -n 80
  echo

  echo "=== LIKELY RENDER WINDOWS ==="
  awk '/=== LIKELY RENDER WINDOWS ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | sed '/^[[:space:]]*$/d' | head -n 120
  echo

  echo "=== GLOBAL STRING TRACE WINDOWS ==="
  awk '/=== GLOBAL STRING TRACE WINDOWS ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | sed '/^[[:space:]]*$/d' | head -n 120
  echo

  echo "=== NEXT PATCH TARGET ==="
  echo "Patch only the exact render expression or formatter shown above that still emits confidence=insufficient."
  echo
} | tee "${OUT}"
