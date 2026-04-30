#!/bin/bash
set -euo pipefail

WORKER_FILE="server.mjs"

if ! grep -q "routeRetryExecution" "$WORKER_FILE"; then
  echo "WIRING RETRY EXECUTION ROUTER INTO SERVER..."

  sed -i '' "1s|^|const { routeRetryExecution } = require('./retry_execution_router');\n|" "$WORKER_FILE"
fi

echo "NOTE: ensure delegate-task pipeline applies routeRetryExecution before enqueue"
