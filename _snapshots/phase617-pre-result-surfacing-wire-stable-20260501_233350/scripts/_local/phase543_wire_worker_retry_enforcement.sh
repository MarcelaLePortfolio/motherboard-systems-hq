#!/bin/bash
set -euo pipefail

FILE=$(ls server/*worker*.mjs 2>/dev/null | head -n 1)

if [[ -z "$FILE" ]]; then
  echo "NO WORKER FILE FOUND"
  exit 1
fi

if ! grep -q "enforceWorkerRetryContract" "$FILE"; then
  sed -i '' "1s|^|const { enforceWorkerRetryContract } = require('./worker_retry_enforcer');\n|" "$FILE"
fi

if ! grep -q "enforceWorkerRetryContract" "$FILE"; then
  echo "MANUAL WIRE REQUIRED: worker file structure mismatch"
  exit 1
fi

echo "Worker retry enforcement wired into: $FILE"
