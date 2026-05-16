
#!/bin/bash

set -euo pipefail

BACKUP_DIR="checkpoints/phase726_pre_runtime_integration"

SOURCE_FILE="server/worker/phase26_task_worker.mjs"

BACKUP_FILE="${BACKUP_DIR}/phase26_task_worker.pre_phase726_runtime_integration.mjs"

mkdir -p "${BACKUP_DIR}"

cp "${SOURCE_FILE}" "${BACKUP_FILE}"

git rev-parse HEAD > "${BACKUP_DIR}/HEAD_BEFORE_RUNTIME_INTEGRATION.txt"

git status --short > "${BACKUP_DIR}/GIT_STATUS_BEFORE_RUNTIME_INTEGRATION.txt"

echo "Saved worker pre-integration backup:"

echo "${BACKUP_FILE}"

