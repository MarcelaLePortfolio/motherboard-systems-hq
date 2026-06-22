
#!/usr/bin/env bash

set -euo pipefail

REPORT="DR_LAUNCHER_AND_MANUAL_CHECKPOINT_INSPECTION.txt"

STAMP="$(date +%Y%m%d_%H%M%S)"

HEAD_SHA="$(git rev-parse --short HEAD)"

BUNDLE="backups/manual_repo_checkpoint_${STAMP}_${HEAD_SHA}.bundle"

SOURCE="backups/manual_source_checkpoint_${STAMP}_${HEAD_SHA}.tar.gz"

NOTE="backups/manual_checkpoint_${STAMP}_${HEAD_SHA}.txt"

{

  echo "===== DR LAUNCHER AND MANUAL CHECKPOINT INSPECTION ====="

  date

  echo

  echo "===== CURRENT HEAD ====="

  git log --oneline -5

  echo

  echo "===== DR LAUNCHER ====="

  sed -n '1,220p' /Users/marcela-dev/bin/dr || true

  echo

  echo "===== CREATE MANUAL REPO BUNDLE ====="

  git bundle create "$BUNDLE" --all

  ls -lh "$BUNDLE"

  echo

  echo "===== CREATE MANUAL SOURCE ARCHIVE ====="

  tar \

    --exclude='./backups' \

    --exclude='./node_modules' \

    --exclude='./.git' \

    -czf "$SOURCE" .

  ls -lh "$SOURCE"

  echo

  echo "===== WRITE CHECKPOINT NOTE ====="

  cat > "$NOTE" << TXT

Manual disaster checkpoint

Timestamp: $STAMP

HEAD: $(git rev-parse HEAD)

Branch: $(git branch --show-current)

Validated state: task card fallback recovery sealed; dashboard health OK; /api/tasks OK.

Bundle: $BUNDLE

Source: $SOURCE

TXT

  cat "$NOTE"

  echo

  echo "===== VERIFY NEW BACKUP ARTIFACTS ====="

  ls -lht backups | head -20

} | tee "$REPORT"

git add "$REPORT" "$NOTE" inspect-dr-launcher-and-create-manual-checkpoint.sh

git commit -m "Record manual disaster checkpoint"

git push

