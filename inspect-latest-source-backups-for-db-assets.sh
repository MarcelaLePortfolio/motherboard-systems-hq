
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="LATEST_SOURCE_BACKUP_DB_ASSET_INSPECTION.txt"

rm -f "$OUTPUT"

{

  echo "===== LATEST SOURCE BACKUP DB ASSET INSPECTION ====="

  date

  echo

  echo "===== LOCAL SOURCE TARBALLS ====="

  find ./backups -maxdepth 1 -type f -name "source_*.tar.gz" | sort | tail -10

  echo

  echo "===== RIO DRIVE SOURCE TARBALLS ====="

  find "/Volumes/Rio Drive/backups" -maxdepth 1 -type f -name "source_*.tar.gz" | sort | tail -10

  echo

  echo "===== INSPECT LOCAL TARBALL CONTENTS ====="

  find ./backups -maxdepth 1 -type f -name "source_*.tar.gz" | sort | tail -5 | while read -r tarfile; do

    echo

    echo "----- $tarfile -----"

    tar -tzf "$tarfile" 2>/dev/null | grep -Ei \

      'postgres|pgdata|docker|volume|database|\.db$|sqlite|drizzle|migration|schema|task|agent_brain|compose|supabase' \

      | head -200 || true

  done

  echo

  echo "===== INSPECT RIO DRIVE TARBALL CONTENTS ====="

  find "/Volumes/Rio Drive/backups" -maxdepth 1 -type f -name "source_*.tar.gz" | sort | tail -5 | while read -r tarfile; do

    echo

    echo "----- $tarfile -----"

    tar -tzf "$tarfile" 2>/dev/null | grep -Ei \

      'postgres|pgdata|docker|volume|database|\.db$|sqlite|drizzle|migration|schema|task|agent_brain|compose|supabase' \

      | head -200 || true

  done

  echo

  echo "===== LIVE DOCKER VOLUMES ====="

  docker volume ls || true

  echo

  echo "===== LIVE CONTAINERS ====="

  docker ps -a || true

  echo

  echo "===== POSSIBLE LOCAL SQLITE FILES ====="

  find . -type f \( -name "*.db" -o -name "*.sqlite" -o -name "*.sqlite3" \) 2>/dev/null | head -200

} | tee "$OUTPUT"

echo

echo "Inspection complete -> $OUTPUT"

