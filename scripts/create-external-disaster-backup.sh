
#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

DRIVE="/Volumes/Rio Drive"

SNAPSHOT_ROOT="$DRIVE/Motherboard_Storage/snapshots"

TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"

BACKUP_DIR="$SNAPSHOT_ROOT/full-disaster-recovery-$TIMESTAMP"

WRONG_ROOT="$DRIVE/MOTHERBOARD_SYSTEMS_DR"

QUARANTINE_DIR="$SNAPSHOT_ROOT/_incomplete-or-misfiled"

if [ ! -d "$DRIVE" ]; then

  echo "ERROR: Rio Drive is not mounted."

  exit 1

fi

mkdir -p "$SNAPSHOT_ROOT" "$QUARANTINE_DIR"

mkdir -p "$BACKUP_DIR/git" "$BACKUP_DIR/docker" "$BACKUP_DIR/system" "$BACKUP_DIR/package-inventory" "$BACKUP_DIR/shell" "$BACKUP_DIR/pm2" "$BACKUP_DIR/env-inventory" "$BACKUP_DIR/artifacts" "$BACKUP_DIR/restore"

if [ -d "$WRONG_ROOT" ]; then

  mv "$WRONG_ROOT" "$QUARANTINE_DIR/MOTHERBOARD_SYSTEMS_DR_misfiled_$TIMESTAMP"

fi

git -C "$REPO_ROOT" rev-parse HEAD > "$BACKUP_DIR/git/HEAD.txt"

git -C "$REPO_ROOT" branch -a > "$BACKUP_DIR/git/branches.txt"

git -C "$REPO_ROOT" tag > "$BACKUP_DIR/git/tags.txt"

git -C "$REPO_ROOT" status --short > "$BACKUP_DIR/git/status.txt"

git -C "$REPO_ROOT" log --oneline -100 > "$BACKUP_DIR/git/log.txt"

git -C "$REPO_ROOT" remote -v > "$BACKUP_DIR/git/remotes.txt"

git -C "$REPO_ROOT" bundle create "$BACKUP_DIR/git/motherboard-systems-hq.bundle" --all

shasum -a 256 "$BACKUP_DIR/git/motherboard-systems-hq.bundle" > "$BACKUP_DIR/git/bundle-checksum.txt"

tar \

  --exclude=".git" \

  --exclude="node_modules" \

  --exclude=".next" \

  --exclude="tmp" \

  --exclude=".DS_Store" \

  -czf "$BACKUP_DIR/artifacts/source-worktree.tar.gz" \

  -C "$(dirname "$REPO_ROOT")" \

  "$(basename "$REPO_ROOT")"

if [ -d "$REPO_ROOT/ARTIFACT_SNAPSHOTS" ]; then

  tar -czf "$BACKUP_DIR/artifacts/artifact-snapshots.tar.gz" -C "$REPO_ROOT" ARTIFACT_SNAPSHOTS

fi

if [ -d "$REPO_ROOT/DISASTER_RECOVERY" ]; then

  tar -czf "$BACKUP_DIR/artifacts/repo-disaster-recovery-folder.tar.gz" -C "$REPO_ROOT" DISASTER_RECOVERY

fi

docker ps -a > "$BACKUP_DIR/docker/docker-ps-a.txt" 2>/dev/null || true

docker images > "$BACKUP_DIR/docker/docker-images.txt" 2>/dev/null || true

docker volume ls > "$BACKUP_DIR/docker/docker-volumes.txt" 2>/dev/null || true

docker compose -f "$REPO_ROOT/docker-compose.yml" config > "$BACKUP_DIR/docker/compose-config.yml" 2>/dev/null || true

docker compose -f "$REPO_ROOT/docker-compose.yml" ps > "$BACKUP_DIR/docker/compose-ps.txt" 2>/dev/null || true

uname -a > "$BACKUP_DIR/system/uname.txt"

sw_vers > "$BACKUP_DIR/system/macos-version.txt"

whoami > "$BACKUP_DIR/system/user.txt"

pwd > "$BACKUP_DIR/system/terminal-path.txt"

echo "$REPO_ROOT" > "$BACKUP_DIR/system/project-path.txt"

date > "$BACKUP_DIR/system/backup-created-at.txt"

brew list > "$BACKUP_DIR/package-inventory/brew-list.txt" 2>/dev/null || true

brew list --cask > "$BACKUP_DIR/package-inventory/brew-cask-list.txt" 2>/dev/null || true

node -v > "$BACKUP_DIR/package-inventory/node-version.txt" 2>/dev/null || true

npm -v > "$BACKUP_DIR/package-inventory/npm-version.txt" 2>/dev/null || true

pnpm -v > "$BACKUP_DIR/package-inventory/pnpm-version.txt" 2>/dev/null || true

python3 --version > "$BACKUP_DIR/package-inventory/python-version.txt" 2>/dev/null || true

cp "$REPO_ROOT/package.json" "$BACKUP_DIR/package-inventory/package.json" 2>/dev/null || true

cp "$REPO_ROOT/package-lock.json" "$BACKUP_DIR/package-inventory/package-lock.json" 2>/dev/null || true

cp "$REPO_ROOT/pnpm-lock.yaml" "$BACKUP_DIR/package-inventory/pnpm-lock.yaml" 2>/dev/null || true

cp "$HOME/.zshrc" "$BACKUP_DIR/shell/zshrc" 2>/dev/null || true

git config --global --list > "$BACKUP_DIR/shell/git-global-config.txt" 2>/dev/null || true

pm2 list > "$BACKUP_DIR/pm2/pm2-list.txt" 2>/dev/null || true

pm2 jlist > "$BACKUP_DIR/pm2/pm2-jlist.json" 2>/dev/null || true

pm2 save > "$BACKUP_DIR/pm2/pm2-save-output.txt" 2>/dev/null || true

find "$REPO_ROOT" -maxdepth 3 \( -name ".env" -o -name ".env.*" \) -print > "$BACKUP_DIR/env-inventory/env-files-present.txt" 2>/dev/null || true

find "$REPO_ROOT" -maxdepth 3 \( -name ".env" -o -name ".env.*" \) -exec ls -lh {} \; > "$BACKUP_DIR/env-inventory/env-file-sizes.txt" 2>/dev/null || true

cat > "$BACKUP_DIR/restore/RESTORE_README.md" << RESTORE

# Motherboard Systems Full Disaster Recovery

Created: $TIMESTAMP

Source repo: $REPO_ROOT

Git HEAD: $(git -C "$REPO_ROOT" rev-parse HEAD)

Restore repo from bundle:

\`\`\`bash

git clone git/motherboard-systems-hq.bundle Motherboard_Systems_HQ

cd Motherboard_Systems_HQ

git checkout $(git -C "$REPO_ROOT" branch --show-current)

\`\`\`

Restore worktree archive:

\`\`\`bash

tar -xzf artifacts/source-worktree.tar.gz

\`\`\`

Secrets:

Use the existing separate secrets vault on Rio Drive.

RESTORE

find "$BACKUP_DIR" -type f -exec shasum -a 256 {} \; > "$BACKUP_DIR/MANIFEST_SHA256.txt"

rm -f "$SNAPSHOT_ROOT/latest-full-disaster-recovery"

ln -s "$BACKUP_DIR" "$SNAPSHOT_ROOT/latest-full-disaster-recovery"

echo "Full external disaster recovery backup created:"

echo "$BACKUP_DIR"

