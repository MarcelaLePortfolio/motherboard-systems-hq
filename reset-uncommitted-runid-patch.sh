
#!/usr/bin/env bash

set -euo pipefail

git checkout -- server/tasks-mutations.mjs

docker compose build dashboard

docker compose up -d dashboard

curl -i http://localhost:8080/api/tasks/health

git status --short

git add reset-uncommitted-runid-patch.sh

git commit -m "Reset uncommitted run id handoff patch"

git push

