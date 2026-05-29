
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

