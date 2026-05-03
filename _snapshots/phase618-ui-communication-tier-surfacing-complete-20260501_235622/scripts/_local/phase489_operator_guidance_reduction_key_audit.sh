#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_489_H1_OPERATOR_GUIDANCE_REDUCTION_KEY_AUDIT.txt"
RUNTIME_FILE="$ROOT/routes/diagnostics/operatorGuidanceRuntime.js"
TRACE_FILE="$ROOT/docs/PHASE_489_H1_OPERATOR_GUIDANCE_REDUCTION_SHAPE_INSPECTION.txt"

{
  echo "PHASE 489 — H1 OPERATOR GUIDANCE REDUCTION KEY AUDIT"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo
  echo "LIVE RESULT"
  echo "Operator Guidance body now renders: No guidance available"
  echo "Operator Guidance meta now renders: Sources: diagnostics/system-health"
  echo
  echo "INTERPRETATION"
  echo "Client wiring is now working."
  echo "The remaining issue is server-side reduction content shape."
  echo "We need the exact reduction keys/values to map a real message and confidence."
  echo
  echo "=== REDUCTION BUILDER FILE SNIPPET ==="
  if [[ -f "$RUNTIME_FILE" ]]; then
    line="$(grep -n 'reduceSystemHealthSnapshotToGuidanceReduction' "$RUNTIME_FILE" | head -n 1 | cut -d: -f1 || true)"
    if [[ -n "${line:-}" ]]; then
      start="$(( line > 40 ? line - 40 : 1 ))"
      end="$(( line + 220 ))"
      sed -n "${start},${end}p" "$RUNTIME_FILE"
    else
      echo "Reduction builder symbol not found in $RUNTIME_FILE"
    fi
  else
    echo "Missing runtime file: $RUNTIME_FILE"
  fi
  echo
  echo "=== REDUCTION KEYS FROM PRIOR TRACE FILE ==="
  if [[ -f "$TRACE_FILE" ]]; then
    grep -nE '^REDUCTION KEYS:|^REDUCTION JSON:|^--- FRAME ' "$TRACE_FILE" || true
    echo
    sed -n '/^--- FRAME 1 ---/,$p' "$TRACE_FILE" | sed -n '1,220p'
  else
    echo "Missing trace file: $TRACE_FILE"
  fi
  echo
  echo "=== NEXT ACTION ==="
  echo "Use the observed reduction keys to replace the client fallback with real reduction fields."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
