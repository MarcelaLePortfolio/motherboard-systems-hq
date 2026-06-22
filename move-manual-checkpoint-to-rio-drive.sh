
#!/usr/bin/env bash

set -euo pipefail

RIO_DRIVE="/Volumes/Rio Drive"

DEST="$RIO_DRIVE/backups"

BUNDLE="backups/manual_repo_checkpoint_20260528_191555_0c04c71d.bundle"

SOURCE="backups/manual_source_checkpoint_20260528_191555_0c04c71d.tar.gz"

REPORT="RIO_DRIVE_MANUAL_CHECKPOINT_TRANSFER.txt"

{

  echo "===== RIO DRIVE MANUAL CHECKPOINT TRANSFER ====="

  date

  echo

  echo "===== VERIFY SOURCE ARTIFACTS ====="

  ls -lh "$BUNDLE" "$SOURCE"

  echo

  echo "===== VERIFY RIO DRIVE MOUNT ====="

  ls -ld "$RIO_DRIVE"

  echo

  echo "===== ENSURE DESTINATION ====="

  mkdir -p "$DEST"

  ls -ld "$DEST"

  echo

  echo "===== COPY CHECKPOINT ARTIFACTS ====="

  cp -v "$BUNDLE" "$DEST/"

  cp -v "$SOURCE" "$DEST/"

  echo

  echo "===== VERIFY DESTINATION ARTIFACTS ====="

  ls -lh \

    "$DEST/manual_repo_checkpoint_20260528_191555_0c04c71d.bundle" \

    "$DEST/manual_source_checkpoint_20260528_191555_0c04c71d.tar.gz"

  echo

  echo "===== CURRENT HEAD ====="

  git log --oneline -5

} | tee "$REPORT"

git add move-manual-checkpoint-to-rio-drive.sh "$REPORT"

git commit -m "Record Rio Drive manual checkpoint transfer"

git push

