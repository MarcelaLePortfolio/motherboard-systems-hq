/* eslint-disable import/no-commonjs */
#!/usr/bin/env bash
set -euo pipefail

ARTIFACT_ROOT="test_artifacts/json_state"
LATEST="$(ls -1 ${ARTIFACT_ROOT} 2>/dev/null | sort | tail -n 1 || true)"
[ -z "${LATEST}" ] && { echo "❌ No artifacts found"; exit 1; }

RUN_DIR="${ARTIFACT_ROOT}/${LATEST}"
LOG_DIR="${RUN_DIR}/agent_logs"
mkdir -p "${LOG_DIR}"

copy_if_exists () {
  local src="$1"; local dst="$2"
  if [ -f "${src}" ]; then cp -f "${src}" "${dst}"; fi
}

copy_if_exists "${HOME}/cade.log"         "${LOG_DIR}/cade.log"
copy_if_exists "${HOME}/matilda.log"      "${LOG_DIR}/matilda.log"
copy_if_exists "${HOME}/effie.log"        "${LOG_DIR}/effie.log"
copy_if_exists "./cade.log"               "${LOG_DIR}/cade.log"
copy_if_exists "./matilda.log"            "${LOG_DIR}/matilda.log"
copy_if_exists "./effie.log"              "${LOG_DIR}/effie.log"

pm2 logs --nostream --lines 200 > "${LOG_DIR}/pm2_snapshot.log" || true

echo "📦 Collected logs into ${LOG_DIR}"
