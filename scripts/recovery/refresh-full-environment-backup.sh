
#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-/Users/marcela-dev/Projects/Motherboard_Systems_HQ}"

BACKUP_ROOT="${BACKUP_ROOT:-$HOME/RioDrive/Motherboard_Systems_Backups}"

EXTERNAL_ROOT="$(dirname "$BACKUP_ROOT")"

STAMP="$(date +%Y%m%d-%H%M%S)"

SNAPSHOT_DIR="$BACKUP_ROOT/full-environment-recovery-$STAMP"

if [ ! -d "$PROJECT_ROOT" ]; then

  echo "ERROR: Project root not found: $PROJECT_ROOT"

  exit 1

fi

if [ ! -d "$EXTERNAL_ROOT" ]; then

  echo "ERROR: External drive root not found: $EXTERNAL_ROOT"

  echo "Set BACKUP_ROOT explicitly if RioDrive is mounted somewhere else."

  exit 1

fi

mkdir -p "$SNAPSHOT_DIR"

for dir in git docker system package-inventory shell cloudflare pm2 env-inventory restore; do

  mkdir -p "$SNAPSHOT_DIR/$dir"

done

cd "$PROJECT_ROOT"

git bundle create "$SNAPSHOT_DIR/git/motherboard-systems-hq.bundle" --all

git rev-parse HEAD > "$SNAPSHOT_DIR/git/HEAD.txt"

git branch --all > "$SNAPSHOT_DIR/git/branches.txt"

git tag --list > "$SNAPSHOT_DIR/git/tags.txt"

git status --short --branch > "$SNAPSHOT_DIR/git/status.txt"

git log --oneline --decorate -50 > "$SNAPSHOT_DIR/git/log.txt"

git remote -v > "$SNAPSHOT_DIR/git/remotes.txt"

docker compose config > "$SNAPSHOT_DIR/docker/compose-config.yml" 2>/dev/null || true

docker compose ps > "$SNAPSHOT_DIR/docker/compose-ps.txt" 2>/dev/null || true

docker ps -a > "$SNAPSHOT_DIR/docker/docker-ps-a.txt" 2>/dev/null || true

docker images > "$SNAPSHOT_DIR/docker/docker-images.txt" 2>/dev/null || true

docker volume ls > "$SNAPSHOT_DIR/docker/docker-volumes.txt" 2>/dev/null || true

uname -a > "$SNAPSHOT_DIR/system/uname.txt"

sw_vers > "$SNAPSHOT_DIR/system/macos-version.txt" 2>/dev/null || true

whoami > "$SNAPSHOT_DIR/system/user.txt"

pwd > "$SNAPSHOT_DIR/system/project-path.txt"

date > "$SNAPSHOT_DIR/system/backup-created-at.txt"

brew list > "$SNAPSHOT_DIR/package-inventory/brew-list.txt" 2>/dev/null || true

brew list --cask > "$SNAPSHOT_DIR/package-inventory/brew-cask-list.txt" 2>/dev/null || true

node -v > "$SNAPSHOT_DIR/package-inventory/node-version.txt" 2>/dev/null || true

npm -v > "$SNAPSHOT_DIR/package-inventory/npm-version.txt" 2>/dev/null || true

pnpm -v > "$SNAPSHOT_DIR/package-inventory/pnpm-version.txt" 2>/dev/null || true

python3 --version > "$SNAPSHOT_DIR/package-inventory/python-version.txt" 2>/dev/null || true

cp package.json "$SNAPSHOT_DIR/package-inventory/package.json" 2>/dev/null || true

cp package-lock.json "$SNAPSHOT_DIR/package-inventory/package-lock.json" 2>/dev/null || true

cp pnpm-lock.yaml "$SNAPSHOT_DIR/package-inventory/pnpm-lock.yaml" 2>/dev/null || true

cp yarn.lock "$SNAPSHOT_DIR/package-inventory/yarn.lock" 2>/dev/null || true

cp "$HOME/.zshrc" "$SNAPSHOT_DIR/shell/zshrc" 2>/dev/null || true

cp "$HOME/.bash_profile" "$SNAPSHOT_DIR/shell/bash_profile" 2>/dev/null || true

git config --global --list > "$SNAPSHOT_DIR/shell/git-global-config.txt" 2>/dev/null || true

ls -lah "$HOME/.cloudflared" > "$SNAPSHOT_DIR/cloudflare/cloudflared-directory-listing.txt" 2>/dev/null || true

find "$HOME/.cloudflared" -maxdepth 1 -type f -name "*.json" -print > "$SNAPSHOT_DIR/cloudflare/cloudflared-credential-files.txt" 2>/dev/null || true

find "$HOME" -maxdepth 1 \( -name "*matilda*.log" -o -name "*cade*.log" -o -name "*effie*.log" \) -print > "$SNAPSHOT_DIR/cloudflare/agent-log-files.txt" 2>/dev/null || true

pm2 list > "$SNAPSHOT_DIR/pm2/pm2-list.txt" 2>/dev/null || true

pm2 jlist > "$SNAPSHOT_DIR/pm2/pm2-jlist.json" 2>/dev/null || true

pm2 save > "$SNAPSHOT_DIR/pm2/pm2-save-output.txt" 2>/dev/null || true

find "$PROJECT_ROOT" -maxdepth 3 -type f \( -name ".env" -o -name ".env.*" \) -print > "$SNAPSHOT_DIR/env-inventory/env-files-present.txt"

find "$PROJECT_ROOT" -maxdepth 3 -type f \( -name ".env" -o -name ".env.*" \) -exec sh -c 'for f do printf "%s  " "$f"; wc -c < "$f"; done' sh {} + > "$SNAPSHOT_DIR/env-inventory/env-file-sizes.txt" 2>/dev/null || true

cat > "$SNAPSHOT_DIR/restore/RESTORE_README.md" << RESTORE

# Motherboard Systems HQ Full Environment Recovery Snapshot

Created: $STAMP

## Restore Order

1. Install Homebrew, Git, Node, pnpm/npm, Docker Desktop, cloudflared, and PM2 as needed.

2. Restore repo from git/motherboard-systems-hq.bundle or clone the GitHub remote.

3. Restore required environment files from secure secret storage.

4. Reinstall dependencies using the lockfile present in package inventory.

5. Validate Docker config using docker compose config.

6. Start services using the project runtime instructions.

7. Validate branch, HEAD, tag, Docker status, dashboard, worker, and Postgres health.

## Recovery Anchor

Branch:

$(git branch --show-current)

HEAD:

$(git rev-parse HEAD)

Recent log:

$(git log --oneline --decorate -5)

RESTORE

find "$SNAPSHOT_DIR" -type f -exec shasum {} \; > "$SNAPSHOT_DIR/MANIFEST_SHA1.txt"

shasum "$SNAPSHOT_DIR/git/motherboard-systems-hq.bundle" > "$SNAPSHOT_DIR/git/bundle-checksum.txt"

ln -sfn "$SNAPSHOT_DIR" "$BACKUP_ROOT/latest-full-environment-recovery"

echo "Full environment recovery archive created:"

echo "$SNAPSHOT_DIR"

echo

echo "Bundle checksum:"

cat "$SNAPSHOT_DIR/git/bundle-checksum.txt"

