
#!/usr/bin/env bash

set -euo pipefail

printf '\n--- inspect governed planning route after optional task bridge ---\n'

sed -n '1,260p' server/routes/governed-planning-route.mjs

printf '\n--- inspect task mutation payload support ---\n'

sed -n '1,260p' server/tasks-mutations.mjs

printf '\n--- inspect recent tasks display surfaces ---\n'

git grep -nEi "recent tasks|phase565|task.created|task.completed|task.failed|execution pipeline|Task entered|Task completed|Task failed" public server docs/contracts | head -n 220

printf '\n--- verify latest commits ---\n'

git log --oneline -8

