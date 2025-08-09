#!/usr/bin/env bash
set -euo pipefail

STATE_PATH="memory/agent_chain_state.json"
ARTIFACT_ROOT="test_artifacts/json_state"
TS="$(date +%Y%m%d_%H%M%S)"
RUN_DIR="${ARTIFACT_ROOT}/${TS}"
LOG_DIR="${RUN_DIR}/agent_logs"
LOG_FILE="${RUN_DIR}/state_watch.log"

mkdir -p "${RUN_DIR}" "${LOG_DIR}"

if ! command -v shasum >/dev/null 2>&1; then
  echo "❌ shasum not found."
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "⚠️ jq not found; pretty-print disabled."
  JQ_AVAILABLE=0
else
  JQ_AVAILABLE=1
fi

if [ ! -f "${STATE_PATH}" ]; then
  echo "❌ ${STATE_PATH} not found."
  exit 1
fi

cp -f "${STATE_PATH}" "${RUN_DIR}/state_pre.json" || true

for name in cade matilda effie; do
  for candidate in "~/${name}.log" "${HOME}/${name}.log" "./${name}.log" ; do
    EXPANDED=$(eval echo ${candidate})
    if [ -f "${EXPANDED}" ]; then
      cp -f "${EXPANDED}" "${LOG_DIR}/${name}.log" || true
      break
    fi
  done
done

echo "🕒 Watch started at $(date)" | tee -a "${LOG_FILE}"
echo "Artifacts: ${RUN_DIR}" | tee -a "${LOG_FILE}"

last_sha=""
last_size=""

while true; do
  if [ ! -f "${STATE_PATH}" ]; then
    echo "❗ $(date +%H:%M:%S) State file missing" | tee -a "${LOG_FILE}"
    sleep 1
    continue
  fi

  if [ "${JQ_AVAILABLE}" -eq 1 ]; then
    if ! jq -e . "${STATE_PATH}" >/dev/null 2>&1; then
      echo "❌ $(date +%H:%M:%S) JSON parse error" | tee -a "${LOG_FILE}"
    fi
  fi

  sha=$(shasum -a 256 "${STATE_PATH}" | awk '{print $1}')
  size=$(stat -f%z "${STATE_PATH}" 2>/dev/null || stat -c%s "${STATE_PATH}" 2>/dev/null || echo "NA")

  if [ "$sha" != "$last_sha" ] || [ "$size" != "$last_size" ]; then
    echo "—" | tee -a "${LOG_FILE}"
    echo "⏱️  $(date +%H:%M:%S) change detected | size=${size} | sha=${sha}" | tee -a "${LOG_FILE}"
    if [ "${JQ_AVAILABLE}" -eq 1 ]; then
      echo "----- JSON (pretty) -----" >> "${LOG_FILE}"
      jq . "${STATE_PATH}" >> "${LOG_FILE}" 2>/dev/null || true
      echo "-------------------------" >> "${LOG_FILE}"
    else
      echo "JSON change recorded" >> "${LOG_FILE}"
    fi
    last_sha="$sha"
    last_size="$size"
  fi

  sleep 1
done
