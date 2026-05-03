#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_patch_exact_container_served_artifact_${STAMP}.txt"

CONTAINER_ID="$(docker ps --format '{{.ID}} {{.Ports}} {{.Names}}' 2>/dev/null | awk '/0\.0\.0\.0:8080->|:::8080->/ {print $1; exit}')"
LATEST_DOC="$(ls -t docs/phase487_locate_exact_served_insufficient_artifact_in_container_*.txt 2>/dev/null | head -n 1 || true)"

if [ -z "${CONTAINER_ID:-}" ]; then
  echo "No container currently serving port 8080."
  exit 1
fi

if [ -z "${LATEST_DOC:-}" ]; then
  echo "No container artifact discovery doc found."
  exit 1
fi

TARGET_FILE="$(awk '
  /=== CONTAINER: FILES CONTAINING Confidence: insufficient ===/ {flag=1; next}
  /^=== / {if(flag) exit}
  flag && NF {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0); print; exit}
' "${LATEST_DOC}")"

if [ -z "${TARGET_FILE:-}" ]; then
  TARGET_FILE="$(awk -F'FILE_HIT:' '/FILE_HIT:/ {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2; exit}' "${LATEST_DOC}")"
fi

if [ -z "${TARGET_FILE:-}" ]; then
  echo "Could not determine exact container-served artifact from ${LATEST_DOC}"
  exit 1
fi

HOST_CANDIDATE=""
case "${TARGET_FILE}" in
  /app/*)
    REL="${TARGET_FILE#/app/}"
    if [ -f "${REL}" ]; then
      HOST_CANDIDATE="${REL}"
    fi
    ;;
esac

docker exec "${CONTAINER_ID}" sh -lc "cp '${TARGET_FILE}' '${TARGET_FILE}.phase487.bak.${STAMP}'"

docker exec "${CONTAINER_ID}" sh -lc "sed \
  -e 's/Confidence: insufficient/Confidence: limited/g' \
  -e 's/insufficient<br \\/>/limited<br \\/>/g' \
  -e 's/insufficient<br>/limited<br>/g' \
  -e 's/\"insufficient\"/\"limited\"/g' \
  -e \"s/'insufficient'/'limited'/g\" \
  '${TARGET_FILE}' > '${TARGET_FILE}.phase487.tmp.${STAMP}' && mv '${TARGET_FILE}.phase487.tmp.${STAMP}' '${TARGET_FILE}'"

if [ -n "${HOST_CANDIDATE}" ] && [ -f "${HOST_CANDIDATE}" ]; then
  sed \
    -e 's/Confidence: insufficient/Confidence: limited/g' \
    -e 's/insufficient<br \/>/limited<br \/>/g' \
    -e 's/insufficient<br>/limited<br>/g' \
    -e 's/"insufficient"/"limited"/g' \
    -e "s/'insufficient'/'limited'/g" \
    "${HOST_CANDIDATE}" > "/tmp/phase487_host_candidate_${STAMP}.tmp"
  mv "/tmp/phase487_host_candidate_${STAMP}.tmp" "${HOST_CANDIDATE}"
fi

if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  docker compose restart 2>&1 || docker-compose restart 2>&1 || true
fi

{
  echo "PHASE 487 — PATCH EXACT CONTAINER-SERVED ARTIFACT"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit_before=$(git rev-parse HEAD)"
  echo "container_id=${CONTAINER_ID}"
  echo "source_doc=${LATEST_DOC}"
  echo "target_file=${TARGET_FILE}"
  echo "host_candidate=${HOST_CANDIDATE:-NONE}"
  echo

  echo "=== CONTAINER TARGET CHECK ==="
  docker exec "${CONTAINER_ID}" sh -lc "grep -n -C 3 'Confidence: limited\|Confidence: insufficient\|Awaiting bounded guidance stream\|Live operator guidance will appear here when visibility wiring is active\|Sources: diagnostics/system-health' '${TARGET_FILE}' || true"
  echo

  echo "=== HOST CANDIDATE CHECK ==="
  if [ -n "${HOST_CANDIDATE:-}" ] && [ -f "${HOST_CANDIDATE}" ]; then
    grep -n -C 3 "Confidence: limited\|Confidence: insufficient\|Awaiting bounded guidance stream\|Live operator guidance will appear here when visibility wiring is active\|Sources: diagnostics/system-health" "${HOST_CANDIDATE}" || true
  else
    echo "No host candidate file"
  fi
  echo

  echo "=== SERVED BODY CHECK ==="
  curl -s http://localhost:8080 | grep -n -C 3 "Confidence: limited\|Confidence: insufficient\|Awaiting bounded guidance stream\|Live operator guidance will appear here when visibility wiring is active\|Sources: diagnostics/system-health" || true
  echo
} > "${OUT}"

echo "${OUT}"
