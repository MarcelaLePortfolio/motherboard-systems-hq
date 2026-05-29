
#!/usr/bin/env bash

set -euo pipefail

REPORT="retention-scope-boundary-$(date +%Y%m%d_%H%M%S).md"

ROOT="$HOME/motherboard-backup-system"

MANAGER="$ROOT/snapshot-manager-prod.sh"

{

  echo "# Retention Scope Boundary Verification"

  echo

  echo "## Manager Base Path"

  echo

  grep -n 'BASE=' "$MANAGER" || true

  echo

  echo "## References To backups/"

  echo

  grep -Rni "backups" "$MANAGER" || true

  echo

  echo "## References To Motherboard_External_Backup"

  echo

  grep -Rni "Motherboard_External_Backup" "$MANAGER" || true

  echo

  echo "## References To Motherboard_Storage"

  echo

  grep -Rni "Motherboard_Storage" "$MANAGER" || true

  echo

  echo "## Enumerated Directories"

  echo

  echo "Local backups:"

  du -sh backups 2>/dev/null || true

  echo

  echo "Motherboard_Storage:"

  du -sh "/Volumes/Rio Drive/Motherboard_Storage/snapshots" 2>/dev/null || true

  echo

  echo "Motherboard_External_Backup:"

  du -sh "/Volumes/Rio Drive/Motherboard_External_Backup/snapshots" 2>/dev/null || true

  echo

  echo "## Conclusion"

  echo

  echo "Review the paths above. The retention manager can only govern locations it explicitly references."

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" verify-retention-scope-boundary.sh

git commit -m "Verify retention manager scope boundary"

git push

