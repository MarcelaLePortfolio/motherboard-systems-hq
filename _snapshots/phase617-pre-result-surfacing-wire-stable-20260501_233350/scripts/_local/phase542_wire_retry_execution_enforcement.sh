#!/bin/bash
set -euo pipefail

FILE="server.mjs"

echo "Wiring retry execution enforcement into delegate-task..."

# Insert import if missing
if ! grep -q "retry_execution_router" "$FILE"; then
  sed -i '' "1s|^|const { routeRetryExecution } = require('./retry_execution_router');\n|" "$FILE"
fi

# Inject enforcement into delegate-task handler (best-effort patch)
if grep -q "/api/delegate-task" "$FILE"; then
  awk '
    BEGIN { injected=0 }
    {
      print $0
      if (!injected && /app\.post\(\"\/api\/delegate-task\"/) {
        print "  // PHASE 542 ENFORCEMENT"
        print "  req.body = routeRetryExecution(req.body || {});"
        injected=1
      }
    }
  ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
fi

echo "Verification..."
node --check server.mjs
