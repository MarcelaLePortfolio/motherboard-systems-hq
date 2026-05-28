
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="SERVER_ROUTE_MOUNT_INSPECTION.txt"

{

  echo "===== SERVER ROUTE MOUNT INSPECTION ====="

  date

  echo

  echo "===== IMPORT SECTION ====="

  sed -n '1,60p' server.mjs

  echo

  echo "===== MIDDLEWARE / ROUTE MOUNT SECTION ====="

  sed -n '160,205p' server.mjs

  echo

  echo "===== GOVERNED ROUTE FILE CHECK ====="

  node --check server/routes/governed-planning-route.mjs

  echo

  echo "===== CURRENT GIT HEAD ====="

  git log --oneline -5

  echo

  echo "===== WORKTREE ====="

  git status --short

} | tee "$OUTPUT"

git add inspect-server-route-mounts.sh SERVER_ROUTE_MOUNT_INSPECTION.txt

git commit -m "Inspect server route mount surface"

git push

