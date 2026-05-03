#!/bin/bash
set -euo pipefail

FILE="server.mjs"

if ! grep -q "enforceRetryContract" "$FILE"; then
  sed -i '' "1s|^|const { enforceRetryContract } = require('./server/retry_contract');\n|" "$FILE"
fi

if ! grep -q "enforceRetryContract" "$FILE"; then
  echo "WARNING: manual wiring required in server.mjs"
fi
