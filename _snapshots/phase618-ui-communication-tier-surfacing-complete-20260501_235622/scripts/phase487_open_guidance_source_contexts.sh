#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST_SUMMARY="$(ls -t docs/phase487_failure_boundary_summary_*.txt 2>/dev/null | head -n 1 || true)"
LATEST_TRACE="$(ls -t docs/phase487_guidance_trace_probe_*.txt 2>/dev/null | head -n 1 || true)"

if [ -z "${LATEST_TRACE}" ]; then
  echo "No phase487 guidance trace probe file found in docs/"
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_guidance_source_contexts_${STAMP}.txt"
TMP_FILES="$(mktemp)"

awk '
  /=== STEP 7: TARGET FILE SHORTLIST ===/ { flag=1; next }
  /^=== / { if (flag) exit }
  flag { print }
' "${LATEST_TRACE}" | sed '/^[[:space:]]*$/d' | sort -u > "${TMP_FILES}"

{
  echo "PHASE 487 — GUIDANCE SOURCE CONTEXTS"
  echo "timestamp=${STAMP}"
  echo "summary_file=${LATEST_SUMMARY}"
  echo "trace_file=${LATEST_TRACE}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== SHORTLIST COUNT ==="
  wc -l < "${TMP_FILES}"
  echo

  while IFS= read -r file; do
    [ -n "${file}" ] || continue
    [ -f "${file}" ] || continue

    echo "============================================================"
    echo "FILE: ${file}"
    echo "============================================================"
    echo

    echo "--- MATCHES: insufficient ---"
    rg -n -C 4 "insufficient" "${file}" || true
    echo

    echo "--- MATCHES: guidance ---"
    rg -n -C 4 "Operator Guidance|guidance" "${file}" || true
    echo

    echo "--- MATCHES: status|reason ---"
    rg -n -C 4 "status|reason" "${file}" || true
    echo

    echo "--- MATCHES: fallback|default|useState|initialState ---"
    rg -n -C 4 "fallback|default|useState|initialState" "${file}" || true
    echo

    echo "--- MATCHES: loading|pending|hydrate|hydration|undefined|null ---"
    rg -n -C 4 "loading|pending|hydrate|hydration|undefined|null" "${file}" || true
    echo
  done < "${TMP_FILES}"

  echo "=== INTERPRETATION TARGET ==="
  echo "Find the first source file where:"
  echo "1. guidance render is defined"
  echo "2. displayed label is derived from status/reason"
  echo "3. fallback/default/undefined path can yield insufficient"
  echo
} > "${OUT}"

rm -f "${TMP_FILES}"

echo "${OUT}"
