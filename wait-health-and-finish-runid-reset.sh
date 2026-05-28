
#!/usr/bin/env bash

set -euo pipefail

REPORT="RUNID_RESET_HEALTH_CONFIRMATION.txt"

{

  echo "===== RUN_ID RESET HEALTH CONFIRMATION ====="

  date

  echo

  echo "===== STATUS BEFORE WAIT ====="

  git status --short

  docker compose ps || true

  echo

  echo "===== WAIT FOR HEALTH ====="

  ok=0

  for i in $(seq 1 20); do

    if curl -fsS http://localhost:8080/api/tasks/health >/tmp/runid-health.json 2>/tmp/runid-health.err; then

      ok=1

      echo "health_ok_attempt=$i"

      cat /tmp/runid-health.json

      echo

      break

    fi

    echo "health_wait_attempt=$i"

    sleep 1

  done

  if [ "$ok" != "1" ]; then

    echo "health_failed_after_wait"

    echo

    echo "===== CURL ERR ====="

    cat /tmp/runid-health.err || true

    echo

    echo "===== DASHBOARD LOGS ====="

    docker logs --tail 220 motherboard-systems-hq-clean-dashboard-1 || true

    exit 1

  fi

  echo

  echo "===== FINAL GIT STATUS ====="

  git status --short

} | tee "$REPORT"

git add reset-uncommitted-runid-patch.sh wait-health-and-finish-runid-reset.sh "$REPORT"

git commit -m "Confirm run id patch reset health"

git push

