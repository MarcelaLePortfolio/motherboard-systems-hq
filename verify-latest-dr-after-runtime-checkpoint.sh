
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="LATEST_DR_AFTER_RUNTIME_CHECKPOINT_VERIFICATION.txt"

RIO_ROOT="/Volumes/Rio Drive/backups"

rm -f "$OUTPUT"

echo "===== LATEST DR AFTER RUNTIME CHECKPOINT VERIFICATION =====" | tee "$OUTPUT"

date | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== LOCAL BACKUPS =====" | tee -a "$OUTPUT"

find backups -maxdepth 2 -type f -mtime -1 -exec ls -lh {} \; 2>/dev/null | sort -k6,8 | tail -40 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== RIO DRIVE BACKUPS =====" | tee -a "$OUTPUT"

if [ -d "$RIO_ROOT" ]; then

  find "$RIO_ROOT" -maxdepth 2 -type f -mtime -1 -exec ls -lh {} \; 2>/dev/null | sort -k6,8 | tail -40 | tee -a "$OUTPUT" || true

else

  echo "Rio Drive backup folder not found: $RIO_ROOT" | tee -a "$OUTPUT"

fi

echo "" | tee -a "$OUTPUT"

echo "===== LATEST GIT HEAD =====" | tee -a "$OUTPUT"

git log --oneline -8 | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== WORKTREE =====" | tee -a "$OUTPUT"

git status --short | tee -a "$OUTPUT"

git add verify-latest-dr-after-runtime-checkpoint.sh LATEST_DR_AFTER_RUNTIME_CHECKPOINT_VERIFICATION.txt

git commit -m "Verify latest DR after runtime checkpoint" || true

git push

