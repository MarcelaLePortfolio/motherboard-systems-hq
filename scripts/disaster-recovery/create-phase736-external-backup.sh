
#!/usr/bin/env bash

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

STAMP="$(date +%Y%m%d_%H%M%S)"

SNAPROOT="/Volumes/Rio Drive/Motherboard_External_Backup/snapshots"

DEST="$SNAPROOT/$STAMP"

mkdir -p "$DEST"

git -C "$REPO" bundle create "$DEST/repo.bundle" --all

tar -czf "$DEST/source.tar.gz" --exclude="./node_modules" --exclude="./.git" --exclude="./backups" --exclude="./_restore_test" --exclude="./.next" --exclude="./logs" -C "$REPO" .

git -C "$REPO" rev-parse HEAD > "$DEST/git_commit.txt"

git -C "$REPO" branch --show-current > "$DEST/git_branch.txt"

find "$DEST" -type f -print0 | xargs -0 shasum -a 256 > "$DEST/checksums.sha256"

echo "Created disaster backup: $DEST"

du -sh "$DEST" || true

