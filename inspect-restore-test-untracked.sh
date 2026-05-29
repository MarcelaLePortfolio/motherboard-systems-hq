
#!/usr/bin/env bash

set -euo pipefail

REPORT="restore-test-untracked-inspection-$(date +%Y%m%d_%H%M%S).md"

{

  echo "# Restore Test Untracked Inspection"

  echo

  echo "## Restore Test Status"

  (

    cd backups/_restore_test

    git status --short

  )

  echo

  echo "## Untracked Top-Level Sizes"

  du -sh backups/_restore_test/.backup_excludes 2>/dev/null || true

  du -sh backups/_restore_test/backups 2>/dev/null || true

  du -sh backups/_restore_test/scripts/vault_layer.sh 2>/dev/null || true

  echo

  echo "## Does current repo already have these?"

  ls -l .backup_excludes 2>/dev/null || true

  ls -ld backups 2>/dev/null || true

  ls -l scripts/vault_layer.sh 2>/dev/null || true

  echo

  echo "## Conclusion Aid"

  echo "If only backups/_restore_test/backups is large, it is likely nested backup duplication inside a restored repo."

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" inspect-restore-test-untracked.sh

git commit -m "Inspect restore test untracked files"

git push

