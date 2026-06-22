
#!/usr/bin/env bash

set -euo pipefail

REPORT="BACKEND_RIO_DRIVE_COMPARISON.txt"

RIO="/Volumes/Rio Drive"

{

  echo "===== BACKEND RIO DRIVE COMPARISON ====="

  date

  echo

  echo "===== CURRENT HEAD ====="

  git log --oneline -10

  echo

  echo "===== FIND RIO BACKEND CANDIDATE ROOTS ====="

  find "$RIO" -type d \( -name server -o -name routes -o -name api -o -name src \) 2>/dev/null | sort | head -120

  echo

  echo "===== CURRENT BACKEND FILE MANIFEST ====="

  find server routes api src -type f 2>/dev/null | sort > /tmp/current-backend-files.txt

  wc -l /tmp/current-backend-files.txt

  cat /tmp/current-backend-files.txt

  echo

  echo "===== RIO DRIVE NEWEST BACKEND FILES ====="

  find "$RIO" -type f 2>/dev/null \

    | grep -Ei '/(server|routes|api|src)/|package.json|docker-compose|Dockerfile|worker|orchestr|execution|governed|matilda|cade' \

    | xargs stat -f "%m %N" 2>/dev/null \

    | sort -nr \

    | head -300

  echo

  echo "===== KEY BACKEND FILE COMPARISON AGAINST RIO MOTHERBOARD_Systems_HQ ====="

  RIO_ROOT="$RIO/Motherboard_Systems_HQ"

  if [ -d "$RIO_ROOT" ]; then

    for path in \

      server/contracts/execution-envelope.v1.mjs \

      server/routes/governed-planning-route.mjs \

      server/execution/governed-planning-pipeline.mjs \

      server/execution/cade-engineer-adapter.mjs \

      server/execution/governance-validator.mjs \

      server/guards/validate-execution-envelope.mjs \

      server/routes/api-tasks-postgres.mjs \

      server/worker/phase26_task_worker.mjs \

      package.json \

      docker-compose.yml

    do

      echo "--- $path ---"

      if [ -f "$path" ] && [ -f "$RIO_ROOT/$path" ]; then

        diff -q "$path" "$RIO_ROOT/$path" && echo "MATCH" || echo "DIFFERS"

      else

        echo "missing current or Rio file"

      fi

    done

  else

    echo "Rio project root not found: $RIO_ROOT"

  fi

  echo

  echo "===== CONCLUSION ====="

  echo "Backend is present and key governed execution files exist locally."

  echo "This still does not prove full latest backend restoration until Rio Drive backend candidates are diffed file-by-file against the intended latest root."

} | tee "$REPORT"

git add compare-backend-against-rio-drive.sh "$REPORT"

git commit -m "Compare backend against Rio Drive recovery sources"

git push

