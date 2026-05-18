
#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-/Users/marcela-dev/Projects/Motherboard_Systems_HQ}"

EXTERNAL_ROOT="${EXTERNAL_ROOT:-/Volumes/Rio Drive}"

STORAGE_ROOT="${STORAGE_ROOT:-$EXTERNAL_ROOT/Motherboard_Storage}"

SNAPSHOT_ROOT="${SNAPSHOT_ROOT:-$STORAGE_ROOT/snapshots}"

VAULT_IMAGE="${VAULT_IMAGE:-$STORAGE_ROOT/recovery-vault/Motherboard_Recovery_Vault.sparsebundle}"

VAULT_MOUNT="${VAULT_MOUNT:-/Volumes/Motherboard_Recovery_Vault}"

STAMP="$(date +%Y%m%d-%H%M%S)"

SNAPSHOT_DIR="$SNAPSHOT_ROOT/full-disaster-recovery-$STAMP"

echo "This script refreshes the full disaster-recovery backup layers that change over time."

echo "It updates the external engineering snapshot plus the encrypted recovery vault in one run."

if [ ! -d "$PROJECT_ROOT" ]; then

  echo "ERROR: Project root not found: $PROJECT_ROOT"

  exit 1

fi

if [ ! -d "$EXTERNAL_ROOT" ]; then

  echo "ERROR: External drive not mounted: $EXTERNAL_ROOT"

  exit 1

fi

if [ ! -d "$STORAGE_ROOT" ]; then

  echo "ERROR: Motherboard storage folder not found: $STORAGE_ROOT"

  exit 1

fi

if [ ! -d "$VAULT_MOUNT" ]; then

  if [ ! -d "$VAULT_IMAGE" ]; then

    echo "ERROR: Recovery vault image not found: $VAULT_IMAGE"

    exit 1

  fi

  hdiutil attach "$VAULT_IMAGE"

fi

if [ ! -d "$VAULT_MOUNT" ]; then

  echo "ERROR: Recovery vault did not mount at: $VAULT_MOUNT"

  exit 1

fi

mkdir -p "$SNAPSHOT_DIR"

for dir in git docker system package-inventory shell pm2 env-inventory restore; do

  mkdir -p "$SNAPSHOT_DIR/$dir"

done

mkdir -p \

  "$VAULT_MOUNT/encrypted-secrets/project-env/$STAMP" \

  "$VAULT_MOUNT/cloudflare/$STAMP" \

  "$VAULT_MOUNT/postgres-dumps/$STAMP" \

  "$VAULT_MOUNT/docker-volume-exports/$STAMP" \

  "$VAULT_MOUNT/restore-manifests"

cd "$PROJECT_ROOT"

git bundle create "$SNAPSHOT_DIR/git/motherboard-systems-hq.bundle" --all

git rev-parse HEAD > "$SNAPSHOT_DIR/git/HEAD.txt"

git branch --all > "$SNAPSHOT_DIR/git/branches.txt"

git tag --list > "$SNAPSHOT_DIR/git/tags.txt"

git status --short --branch > "$SNAPSHOT_DIR/git/status.txt"

git log --oneline --decorate -80 > "$SNAPSHOT_DIR/git/log.txt"

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

pm2 list > "$SNAPSHOT_DIR/pm2/pm2-list.txt" 2>/dev/null || true

pm2 jlist > "$SNAPSHOT_DIR/pm2/pm2-jlist.json" 2>/dev/null || true

pm2 save > "$SNAPSHOT_DIR/pm2/pm2-save-output.txt" 2>/dev/null || true

find "$PROJECT_ROOT" -maxdepth 3 -type f \( -name ".env" -o -name ".env.*" \) -print > "$SNAPSHOT_DIR/env-inventory/env-files-present.txt"

find "$PROJECT_ROOT" -maxdepth 3 -type f \( -name ".env" -o -name ".env.*" \) \

  -exec sh -c 'for f do printf "%s  " "$f"; wc -c < "$f"; done' sh {} + \

  > "$SNAPSHOT_DIR/env-inventory/env-file-sizes.txt" 2>/dev/null || true

find "$PROJECT_ROOT" -maxdepth 3 -type f \( -name ".env" -o -name ".env.*" \) \

  -exec cp {} "$VAULT_MOUNT/encrypted-secrets/project-env/$STAMP/" \;

if [ -d "$HOME/.cloudflared" ]; then

  cp -R "$HOME/.cloudflared" "$VAULT_MOUNT/cloudflare/$STAMP/cloudflared-config"

fi

docker compose exec -T postgres pg_dump -U postgres \

  > "$VAULT_MOUNT/postgres-dumps/$STAMP/motherboard_postgres.sql" 2>/dev/null || true

docker volume ls --format '{{.Name}}' \

  > "$VAULT_MOUNT/docker-volume-exports/$STAMP/docker-volume-list.txt" 2>/dev/null || true

while read -r VOLUME; do

  [ -z "$VOLUME" ] && continue

  docker run --rm \

    -v "${VOLUME}:/volume:ro" \

    -v "$VAULT_MOUNT/docker-volume-exports/$STAMP:/backup" \

    alpine \

    tar czf "/backup/${VOLUME}.tar.gz" -C /volume . 2>/dev/null || true

done < "$VAULT_MOUNT/docker-volume-exports/$STAMP/docker-volume-list.txt"

cat > "$SNAPSHOT_DIR/restore/RESTORE_README.md" << RESTORE

# Motherboard Systems HQ Full Disaster Recovery Snapshot

Created: $STAMP

## Restore Order

1. Mount the external drive.

2. Mount the encrypted recovery vault.

3. Install Homebrew, Git, Node, pnpm/npm, Docker Desktop, cloudflared, and PM2.

4. Restore the repo from git/motherboard-systems-hq.bundle or clone the GitHub remote.

5. Restore .env files from the recovery vault.

6. Restore Cloudflare credentials from the recovery vault.

7. Reinstall dependencies from package inventory lockfiles.

8. Validate Docker config with docker compose config.

9. Restore Postgres from the latest vault dump if needed.

10. Restore Docker volumes from the latest vault exports if needed.

11. Start services and validate dashboard, worker, Postgres, SSE, and artifact preview routes.

## Recovery Anchor

Branch:

$(git branch --show-current)

HEAD:

$(git rev-parse HEAD)

Recent log:

$(git log --oneline --decorate -8)

External snapshot:

$SNAPSHOT_DIR

Vault timestamp:

$STAMP

RESTORE

cat > "$VAULT_MOUNT/restore-manifests/RECOVERY_MANIFEST_$STAMP.txt" << RESTORE

Motherboard Systems HQ Recovery Vault Refresh

Created: $STAMP

Associated engineering snapshot:

$SNAPSHOT_DIR

Branch:

$(git branch --show-current)

HEAD:

$(git rev-parse HEAD)

Includes:

- .env files

- Cloudflare credentials/configuration

- Postgres dump

- Docker volume exports

- restore manifest

Restore note:

Use the newest timestamped folder in each vault section unless intentionally rolling back to an older state.

RESTORE

find "$SNAPSHOT_DIR" -type f -exec shasum {} \; > "$SNAPSHOT_DIR/MANIFEST_SHA1.txt"

shasum "$SNAPSHOT_DIR/git/motherboard-systems-hq.bundle" \

  > "$SNAPSHOT_DIR/git/bundle-checksum.txt"

find "$VAULT_MOUNT" -type f -maxdepth 5 -exec shasum {} \; \

  > "$VAULT_MOUNT/restore-manifests/VAULT_MANIFEST_SHA1_$STAMP.txt"

ln -sfn "$SNAPSHOT_DIR" "$SNAPSHOT_ROOT/latest-full-disaster-recovery"

echo

echo "Full disaster-recovery backup completed."

echo "Engineering snapshot: $SNAPSHOT_DIR"

echo "Recovery vault: $VAULT_MOUNT"

echo

echo "Bundle checksum:"

cat "$SNAPSHOT_DIR/git/bundle-checksum.txt"

