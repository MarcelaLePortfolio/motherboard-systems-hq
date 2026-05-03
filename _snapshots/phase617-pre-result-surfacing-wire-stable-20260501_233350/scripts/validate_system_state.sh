#!/bin/bash
set -euo pipefail

echo "Validating system state..."

if git diff --cached --name-only | grep -E "^snapshots/"; then
  echo "ERROR: Snapshot modification detected in staged changes."
  exit 1
fi

if ! test -f server/retry_contract.js; then
  echo "ERROR: Missing retry contract."
  exit 1
fi

if ! grep -q "routeRetryExecution" server/retry_execution_router.js; then
  echo "ERROR: Missing retry routing layer."
  exit 1
fi

if ! grep -q "enforceWorkerRetryContract" server/worker_retry_enforcer.js; then
  echo "ERROR: Missing worker retry enforcement."
  exit 1
fi

node --check server.mjs

echo "SYSTEM STATE VALID ✔"
