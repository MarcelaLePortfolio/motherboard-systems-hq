
#!/usr/bin/env bash

set -euo pipefail

REPORT="RIO_DRIVE_MANUAL_CHECKPOINT_VERIFY.txt"

RIO_DEST="/Volumes/Rio Drive/backups"

BUNDLE="$RIO_DEST/manual_repo_checkpoint_20260528_191555_0c04c71d.bundle"

SOURCE="$RIO_DEST/manual_source_checkpoint_20260528_191555_0c04c71d.tar.gz"

{

  echo "===== RIO DRIVE MANUAL CHECKPOINT VERIFY ====="

  date

  echo

  echo "===== IMPORTANT NOTE ====="

  echo "The .bundle file is not executable shell code."

  echo "If it was run directly, command-not-found errors are expected and do not by themselves prove corruption."

  echo

  echo "===== VERIFY FILES EXIST ====="

  ls -lh "$BUNDLE" "$SOURCE"

  echo

  echo "===== VERIFY GIT BUNDLE ====="

  git bundle verify "$BUNDLE"

  echo

  echo "===== VERIFY SOURCE ARCHIVE CAN BE READ ====="

  tar -tzf "$SOURCE" >/tmp/rio_drive_source_archive_listing.txt

  wc -l /tmp/rio_drive_source_archive_listing.txt

  head -20 /tmp/rio_drive_source_archive_listing.txt

  echo

  echo "===== CHECKSUMS ====="

  shasum -a 256 "$BUNDLE" "$SOURCE"

  echo

  echo "===== CURRENT HEAD ====="

  git log --oneline -5

  echo

  echo "===== GIT STATUS ====="

  git status --short

} | tee "$REPORT"

git add verify-rio-drive-manual-checkpoint.sh "$REPORT"

git commit -m "Verify Rio Drive manual checkpoint"

git push

