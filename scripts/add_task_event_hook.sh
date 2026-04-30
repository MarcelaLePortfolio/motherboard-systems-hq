#!/bin/bash
set -euo pipefail

FILE="server.mjs"

if ! grep -q "logTaskEvent" "$FILE"; then
  echo "ERROR: logger not injected"
  exit 1
fi

# best-effort injection (non-breaking)
if grep -q "app.post(\"/api/delegate-task\"" "$FILE"; then
  awk '
    BEGIN { inserted=0 }
    {
      print $0
      if (!inserted && /app\.post\(\"\/api\/delegate-task\"/) {
        print "  // PHASE EVENT HOOK"
        print "  await logTaskEvent(db, {"
        print "    task_id: req.body?.meta?.retry_of_task_id || req.body?.task_id || \"unknown\","
        print "    kind: \"task.event.received\","
        print "    actor: \"api\","
        print "    payload: req.body"
        print "  });"
        inserted=1
      }
    }
  ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
fi

node --check server.mjs
