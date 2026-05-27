/* eslint-disable import/no-commonjs */
#!/usr/bin/env bash
set -euo pipefail

LABEL="${1:-pre}"

STATE_PATH="memory/agent_chain_state.json"
ARTIFACT_ROOT="test_artifacts/json_state"
TS="$(date +%Y%m%d_%H%M%S)"
RUN_DIR="${ARTIFACT_ROOT}/${TS}"
mkdir -p "${RUN_DIR}"

if [ -f "${STATE_PATH}" ]; then
  cp -f "${STATE_PATH}" "${RUN_DIR}/state_${LABEL}.json"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "${RUN_DIR}/state_${LABEL}.json" | awk '{print $1}' > "${RUN_DIR}/state_${LABEL}.sha256"
  fi
  echo "✅ Snapshot ${LABEL} saved to ${RUN_DIR}"
else
  echo "⚠️ No state file found; creating placeholder."
  echo "{}" > "${RUN_DIR}/state_${LABEL}.json"
fi
