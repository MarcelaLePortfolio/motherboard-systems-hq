
#!/usr/bin/env bash

set -euo pipefail

REPORT="nested-restore-test-backups-removal-$(date +%Y%m%d_%H%M%S).md"

TARGET="backups/_restore_test/backups"

{

  echo "# Nested Restore-Test Backups Removal"

  echo

  echo "## Before"

  du -sh "$TARGET" 2>/dev/null || true

  du -sh backups/_restore_test 2>/dev/null || true

  du -sh backups 2>/dev/null || true

  echo

  echo "## Removing"

  echo "$TARGET"

} > "$REPORT"

rm -rf "$TARGET"

{

  echo

  echo "## After"

  du -sh "$TARGET" 2>/dev/null || echo "$TARGET removed"

  du -sh backups/_restore_test 2>/dev/null || true

  du -sh backups 2>/dev/null || true

  echo

  echo "## Restore Test Remaining Git Status"

  (

    cd backups/_restore_test

    git status --short

  )

} >> "$REPORT"

cat "$REPORT"

git add "$REPORT" remove-nested-restore-test-backups.sh

git commit -m "Remove nested restore test backup duplication"

git push

