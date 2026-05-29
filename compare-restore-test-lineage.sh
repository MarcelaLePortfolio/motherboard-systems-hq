
#!/usr/bin/env bash

set -euo pipefail

REPORT="restore-test-lineage-comparison-$(date +%Y%m%d_%H%M%S).md"

{

  echo "# Restore Test Lineage Comparison"

  echo

  echo "## Current Repo"

  git rev-parse HEAD

  git branch --show-current

  git remote -v

  echo

  echo "## Restore Test Repo"

  (

    cd backups/_restore_test

    git rev-parse HEAD

    git branch --show-current

    git remote -v

  )

  echo

  echo "## Commits in restore_test not in current repo"

  (

    cd backups/_restore_test

    git log --oneline "$(git -C ../.. rev-parse HEAD)..HEAD" -20 || true

  )

  echo

  echo "## Commits in current repo not in restore_test"

  git log --oneline "$(git -C backups/_restore_test rev-parse HEAD)..HEAD" -20 || true

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" compare-restore-test-lineage.sh

git commit -m "Compare restore test lineage"

git push

