
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="DOCKER_RESET_COMPLETION_VERIFICATION.txt"

rm -f "$OUTPUT"

{

  echo "===== DOCKER RESET COMPLETION VERIFICATION ====="

  date

  echo

  echo "===== DOCKER VERSION ====="

  docker version

  echo

  echo "===== DOCKER SYSTEM DF ====="

  docker system df

  echo

  echo "===== DOCKER VOLUMES ====="

  docker volume ls

  echo

  echo "===== DOCKER CONTAINERS ====="

  docker ps -a

  echo

  echo "===== GIT HEAD ====="

  git log --oneline -5

  echo

  echo "===== WORKTREE ====="

  git status --short

} | tee "$OUTPUT"

git add verify-docker-reset-complete.sh DOCKER_RESET_COMPLETION_VERIFICATION.txt

git commit -m "Verify Docker reset completion" || true

git push

