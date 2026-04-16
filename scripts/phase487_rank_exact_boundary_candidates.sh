#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST_CONTEXT="$(ls -t docs/phase487_guidance_source_contexts_*.txt 2>/dev/null | head -n 1 || true)"
if [ -z "${LATEST_CONTEXT}" ]; then
  echo "No phase487 guidance source contexts file found in docs/"
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_exact_boundary_candidates_${STAMP}.txt"
TMP="$(mktemp)"

awk '
  /^FILE: / { file=$0; sub(/^FILE: /,"",file); next }
  {
    if ($0 ~ /insufficient|guidance|status|reason|fallback|default|useState|initialState|loading|pending|hydrate|hydration|undefined|null/) {
      print file "\t" $0
    }
  }
' "${LATEST_CONTEXT}" > "${TMP}"

{
  echo "PHASE 487 — EXACT BOUNDARY CANDIDATES"
  echo "timestamp=${STAMP}"
  echo "source_context=${LATEST_CONTEXT}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== FILES WITH HIGHEST SIGNAL DENSITY ==="
  cut -f1 "${TMP}" | sed '/^[[:space:]]*$/d' | sort | uniq -c | sort -nr | head -n 20
  echo

  echo "=== TOP INSUFFICIENT MATCHES BY FILE ==="
  grep -i $'\t.*insufficient' "${TMP}" | head -n 120 || true
  echo

  echo "=== TOP FALLBACK / DEFAULT / STATE MATCHES BY FILE ==="
  grep -Ei $'\t.*(fallback|default|useState|initialState|loading|pending|hydrate|hydration|undefined|null)' "${TMP}" | head -n 160 || true
  echo

  echo "=== TOP STATUS / REASON MATCHES BY FILE ==="
  grep -Ei $'\t.*(status|reason)' "${TMP}" | head -n 160 || true
  echo

  echo "=== RECOMMENDED MANUAL INSPECTION ORDER ==="
  cut -f1 "${TMP}" | sed '/^[[:space:]]*$/d' | sort | uniq -c | sort -nr | head -n 5 | awk '{print NR ". " $2}'
  echo

  echo "=== DECISION FRAME ==="
  echo "Pick the first file that contains all three:"
  echo "1. guidance render/output"
  echo "2. status/reason read"
  echo "3. fallback/default/undefined path"
  echo
  echo "That file is the most likely exact UI failure boundary."
} > "${OUT}"

rm -f "${TMP}"

echo "${OUT}"
