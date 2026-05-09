
#!/bin/bash

set -euo pipefail

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

git rm -f PHASE717_RECENT_TASKS_DENSITY_INSPECTION.sh

cat > PHASE717_DENSITY_HELPER_REVERTED.md << 'NOTE'

# Phase 717 Density Helper Reverted

The Recent Tasks density inspection helper was removed after three failed shell-portability attempts.

Failed attempts:

- grep argument portability failure

- malformed find continuation failure

- pipeline syntax failure

Recovery action:

- stop patching this helper

- return to stable runtime

- use direct manual inspection commands next

- avoid committing another speculative helper until exact file targets are confirmed

NOTE

git status --short

docker compose ps

curl -fsS http://localhost:3000 >/tmp/phase717_dashboard_recovery_check.html

wc -c /tmp/phase717_dashboard_recovery_check.html

git add PHASE717_DENSITY_HELPER_REVERTED.md

git commit -m "Phase 717: revert failed density inspection helper"

git push origin dev

