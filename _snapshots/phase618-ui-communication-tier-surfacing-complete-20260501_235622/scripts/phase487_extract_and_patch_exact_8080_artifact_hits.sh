#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_extract_and_patch_exact_8080_artifact_hits_${STAMP}.txt"
LATEST_DOC="$(ls -t docs/phase487_locate_exact_served_insufficient_artifact_in_container_*.txt 2>/dev/null | head -n 1 || true)"
CONTAINER_ID="$(docker ps --format '{{.ID}} {{.Ports}} {{.Names}}' 2>/dev/null | awk '/0\.0\.0\.0:8080->|:::8080->/ {print $1; exit}')"

if [ -z "${LATEST_DOC}" ]; then
  echo "No locate doc found."
  exit 1
fi

if [ -z "${CONTAINER_ID}" ]; then
  echo "No 8080 container found."
  exit 1
fi

TMP_TARGETS="$(mktemp)"

awk -F'FILE_HIT:' '
  /FILE_HIT:/ {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
    if ($2 != "") print $2
  }
' "${LATEST_DOC}" | sort -u > "${TMP_TARGETS}"

if [ ! -s "${TMP_TARGETS}" ]; then
  awk '
    /=== CONTAINER: FILES CONTAINING Confidence: insufficient ===/ {flag=1; next}
    /^=== / {if(flag) exit}
    flag && NF {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
      if ($0 != "") print $0
    }
  ' "${LATEST_DOC}" | sort -u > "${TMP_TARGETS}"
fi

{
  echo "PHASE 487 — EXTRACT AND PATCH EXACT 8080 ARTIFACT HITS"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit_before=$(git rev-parse HEAD)"
  echo "container_id=${CONTAINER_ID}"
  echo "source_doc=${LATEST_DOC}"
  echo

  echo "=== TARGET FILES ==="
  cat "${TMP_TARGETS}" || true
  echo

  while IFS= read -r target; do
    [ -n "${target}" ] || continue

    echo "--- PATCHING CONTAINER TARGET: ${target} ---"
    docker exec "${CONTAINER_ID}" sh -lc "test -f '${target}' || exit 0; cp '${target}' '${target}.phase487bak.${STAMP}'"
    docker exec "${CONTAINER_ID}" sh -lc "
      if test -f '${target}'; then
        sed \
          -e 's/Confidence: insufficient/Confidence: limited/g' \
          -e 's/insufficient<br \\/>/limited<br \\/>/g' \
          -e 's/insufficient<br>/limited<br>/g' \
          -e 's/\"insufficient\"/\"limited\"/g' \
          -e \"s/'insufficient'/'limited'/g\" \
          '${target}' > '${target}.phase487tmp.${STAMP}' &&
        mv '${target}.phase487tmp.${STAMP}' '${target}'
      fi
    " || true

    if [[ "${target}" == /app/* ]]; then
      host_rel="${target#/app/}"
      if [ -f "${host_rel}" ]; then
        sed \
          -e 's/Confidence: insufficient/Confidence: limited/g' \
          -e 's/insufficient<br \/>/limited<br \/>/g' \
          -e 's/insufficient<br>/limited<br>/g' \
          -e 's/"insufficient"/"limited"/g' \
          -e "s/'insufficient'/'limited'/g" \
          "${host_rel}" > "/tmp/phase487_host_patch_${STAMP}" &&
        mv "/tmp/phase487_host_patch_${STAMP}" "${host_rel}"
        echo "HOST_SYNC:${host_rel}"
      fi
    fi

    echo "--- POST-PATCH CHECK: ${target} ---"
    docker exec "${CONTAINER_ID}" sh -lc "grep -n -C 3 'Confidence: limited\|Confidence: insufficient\|Awaiting bounded guidance stream\|Live operator guidance will appear here when visibility wiring is active\|Sources: diagnostics/system-health' '${target}' || true"
    echo
  done < "${TMP_TARGETS}"

  echo "=== DOCKER RESTART ==="
  docker compose restart 2>&1 || docker-compose restart 2>&1 || true
  echo

  echo "=== SERVED BODY CHECK ==="
  curl -s http://localhost:8080 | grep -n -C 3 "Confidence: limited\|Confidence: insufficient\|Awaiting bounded guidance stream\|Live operator guidance will appear here when visibility wiring is active\|Sources: diagnostics/system-health" || true
  echo
} > "${OUT}"

rm -f "${TMP_TARGETS}"

echo "${OUT}"
