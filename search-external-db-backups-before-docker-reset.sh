
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="EXTERNAL_DB_BACKUP_SEARCH_BEFORE_DOCKER_RESET.txt"

rm -f "$OUTPUT"

{

  echo "===== EXTERNAL DB BACKUP SEARCH BEFORE DOCKER RESET ====="

  date

  echo

  echo "===== SEARCH SQL / DUMP / POSTGRES FILES ====="

  find . "/Volumes/Rio Drive/backups" \

    -maxdepth 6 \

    -type f \( \

      -iname "*.sql" -o \

      -iname "*.dump" -o \

      -iname "*postgres*" -o \

      -iname "*pgdata*" -o \

      -iname "*database*" -o \

      -iname "*db*" \

    \) 2>/dev/null | sort | head -300

  echo

  echo "===== RIO SOURCE BACKUPS CONTENT PREVIEW ====="

  find "/Volumes/Rio Drive/backups" -maxdepth 1 -type f -iname "source_*.tar.gz" 2>/dev/null | sort | tail -10 | while read -r tarfile; do

    echo

    echo "----- $tarfile -----"

    tar -tzf "$tarfile" 2>/dev/null | grep -Ei 'postgres|pgdata|\.sql|\.dump|database|db|drizzle|schema|migration' | head -80 || true

  done

  echo

  echo "===== LOCAL SOURCE BACKUPS CONTENT PREVIEW ====="

  find backups -maxdepth 1 -type f -iname "source_*.tar.gz" 2>/dev/null | sort | tail -10 | while read -r tarfile; do

    echo

    echo "----- $tarfile -----"

    tar -tzf "$tarfile" 2>/dev/null | grep -Ei 'postgres|pgdata|\.sql|\.dump|database|db|drizzle|schema|migration' | head -80 || true

  done

  echo

  echo "===== GIT HEAD ====="

  git log --oneline -5

  echo

  echo "===== WORKTREE ====="

  git status --short

} | tee "$OUTPUT"

git add search-external-db-backups-before-docker-reset.sh EXTERNAL_DB_BACKUP_SEARCH_BEFORE_DOCKER_RESET.txt

git commit -m "Search external DB backups before Docker reset" || true

git push

