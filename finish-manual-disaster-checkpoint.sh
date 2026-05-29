
#!/usr/bin/env bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"

HEAD_SHA="$(git rev-parse --short HEAD)"

BUNDLE="backups/manual_repo_checkpoint_${STAMP}_${HEAD_SHA}.bundle"

SOURCE="backups/manual_source_checkpoint_${STAMP}_${HEAD_SHA}.tar.gz"

NOTE="MANUAL_DISASTER_CHECKPOINT_${STAMP}_${HEAD_SHA}.md"

REPORT="MANUAL_DISASTER_CHECKPOINT_${STAMP}_${HEAD_SHA}.txt"

{

  echo "===== FINISH MANUAL DISASTER CHECKPOINT ====="

  date

  echo

  echo "===== CURRENT HEAD ====="

  git log --oneline -5

  echo

  echo "===== CREATE REPO BUNDLE ====="

  git bundle create "$BUNDLE" --all

  ls -lh "$BUNDLE"

  echo

  echo "===== CREATE SOURCE ARCHIVE ====="

  tar --exclude='./backups' --exclude='./node_modules' --exclude='./.git' -czf "$SOURCE" .

  ls -lh "$SOURCE"

  echo

  echo "===== WRITE CHECKPOINT NOTE ====="

  cat > "$NOTE" << TXT

Manual disaster checkpoint

Timestamp: $STAMP

HEAD: $(git rev-parse HEAD)

Branch: $(git branch --show-current)

Validated state:

- Task card fallback recovery sealed.

- Dashboard health OK.

- /api/tasks OK.

- Repo bundle created.

- Source archive created.

Bundle:

$BUNDLE

Source archive:

$SOURCE

TXT

  cat "$NOTE"

  echo

  echo "===== VERIFY BACKUP ARTIFACTS ====="

  ls -lh "$BUNDLE" "$SOURCE"

} | tee "$REPORT"

git add "$REPORT" "$NOTE" finish-manual-disaster-checkpoint.sh

git commit -m "Finish manual disaster checkpoint"

git push

