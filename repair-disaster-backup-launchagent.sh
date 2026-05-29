
#!/usr/bin/env bash

set -euo pipefail

REPO="$(git rev-parse --show-toplevel)"

PLIST="$HOME/Library/LaunchAgents/com.motherboard.disaster.backup.plist"

REPORT="disaster-backup-launchagent-repair-$(date +%Y%m%d_%H%M%S).md"

OLD_SCRIPT="$HOME/Projects/Motherboard_Systems_HQ/scripts/disaster-recovery/create-phase736-external-backup.sh"

NEW_SCRIPT="$REPO/scripts/disaster-recovery/create-phase736-external-backup.sh"

{

  echo "# Disaster Backup LaunchAgent Repair"

  echo

  echo "Repo: $REPO"

  echo "Plist: $PLIST"

  echo "Old script: $OLD_SCRIPT"

  echo "New script: $NEW_SCRIPT"

  echo

  echo "## Before"

  launchctl print "gui/$(id -u)/com.motherboard.disaster.backup" 2>&1 || true

  echo

  echo "## Script Existence"

  echo "Old exists: $(test -f "$OLD_SCRIPT" && echo YES || echo NO)"

  echo "New exists: $(test -f "$NEW_SCRIPT" && echo YES || echo NO)"

  echo

} > "$REPORT"

if [ ! -f "$NEW_SCRIPT" ]; then

  mkdir -p "$REPO/scripts/disaster-recovery"

  cat > "$NEW_SCRIPT" << 'SCRIPT_EOF'

#!/usr/bin/env bash

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

STAMP="$(date +%Y%m%d_%H%M%S)"

DEST="/Volumes/Rio Drive/Motherboard_External_Backup/snapshots/$STAMP"

mkdir -p "$DEST"

git -C "$REPO" bundle create "$DEST/repo.bundle" --all

tar \

  --exclude="$REPO/node_modules" \

  --exclude="$REPO/.git" \

  --exclude="$REPO/backups" \

  --exclude="$REPO/_restore_test" \

  --exclude="$REPO/.next" \

  -czf "$DEST/source.tar.gz" \

  -C "$REPO" .

git -C "$REPO" rev-parse HEAD > "$DEST/git_commit.txt"

git -C "$REPO" branch --show-current > "$DEST/git_branch.txt"

find "$DEST" -type f -print0 | xargs -0 shasum -a 256 > "$DEST/checksums.sha256"

echo "Created disaster backup: $DEST"

SCRIPT_EOF

  chmod +x "$NEW_SCRIPT"

fi

launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true

python3 - <<PY

from pathlib import Path

plist = Path("$PLIST")

text = plist.read_text()

text = text.replace("$OLD_SCRIPT", "$NEW_SCRIPT")

text = text.replace("$HOME/Projects/Motherboard_Systems_HQ/logs", "$REPO/logs")

plist.write_text(text)

PY

mkdir -p "$REPO/logs"

chmod +x "$NEW_SCRIPT"

launchctl bootstrap "gui/$(id -u)" "$PLIST"

launchctl kickstart -k "gui/$(id -u)/com.motherboard.disaster.backup" || true

{

  echo

  echo "## After"

  launchctl print "gui/$(id -u)/com.motherboard.disaster.backup" 2>&1 || true

  echo

  echo "## Recent External Snapshots"

  ls -ltrh "/Volumes/Rio Drive/Motherboard_External_Backup/snapshots" 2>/dev/null | tail -20 || true

} >> "$REPORT"

cat "$REPORT"

git add "$REPORT" "$NEW_SCRIPT" repair-disaster-backup-launchagent.sh

git commit -m "Repair disaster backup launch agent path"

git push

