/* eslint-disable import/no-commonjs */
#!/usr/bin/env bash
set -euo pipefail

ARTIFACT_ROOT="test_artifacts/json_state"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <timestamp-folder>"
  ls -1 ${ARTIFACT_ROOT} | tail -n 10 || true
  exit 1
fi

RUN_DIR="${ARTIFACT_ROOT}/$1"
SRC="${RUN_DIR}/state_pre.json"
DST="memory/agent_chain_state.json"

if [ ! -f "${SRC}" ]; then
  echo "❌ Not found: ${SRC}"
  exit 1
fi

cp -f "${SRC}" "${DST}"
echo "✅ Restored ${DST} from ${SRC}"
