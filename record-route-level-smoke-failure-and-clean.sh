
#!/usr/bin/env bash

set -euo pipefail

cat > ROUTE_LEVEL_TASK_EVENT_SMOKE_FINDING.txt << 'TXT'

===== ROUTE LEVEL TASK EVENT SMOKE FINDING =====

Finding:

- /api/tasks POST is not mounted in the current restored runtime.

- The route-level smoke script committed at f540fd6d used multiline curl continuations and broke at -H.

- Therefore, that smoke result is not valid evidence about run_id propagation.

- Do not use smoke-api-tasks-complete-event-route.sh as a validation harness.

Current valid evidence:

- /api/tasks-mutations/delegate works after schema migration.

- /api/tasks-mutations/complete updates task rows to done.

- /api/tasks-mutations/complete still fails secondary task.completed event emission because run_id is not reaching appendTaskEvent.

- The older /api/tasks/complete route pattern shows the intended top-level emitTaskEvent({ run_id }) handoff, but that route is not mounted.

TXT

git rm smoke-api-tasks-complete-event-route.sh

git add ROUTE_LEVEL_TASK_EVENT_SMOKE_FINDING.txt

git commit -m "Record invalid route-level task event smoke"

git push

