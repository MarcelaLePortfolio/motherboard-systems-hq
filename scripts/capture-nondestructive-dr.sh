#!/usr/bin/env bash
set -euo pipefail
umask 077

# NON-DESTRUCTIVE DISASTER RECOVERY CAPTURE
#
# Requires separate authorization for execution.
# Requires an independently created and mounted AES-256 encrypted
# sparsebundle containing an APFS filesystem, stored on Rio Drive.
#
# Encryption is provided by the disk image, not the inner APFS volume.
#
# This script does not create, attach, or unlock disk images.
# It does not delete historical backups or execute restoration.
# It does not commit, push, restart, or deploy anything.

REPO="/Users/marcela-dev/Projects/motherboard-systems-hq-clean"
EXPECTED_BRANCH="feature/support-source-references-runtime"
EXTERNAL="/Volumes/Rio Drive"
EXPECTED_IMAGE="$EXTERNAL/backups/Motherboard_Encrypted_DR_AES256.sparsebundle"
EXPECTED_MOUNT="/Volumes/Motherboard Encrypted DR"

die() {
  printf 'DR ERROR: %s\n' "$*" >&2
  exit 1
}

require() {
  command -v "$1" >/dev/null 2>&1 ||
    die "Missing dependency: $1"
}

for tool in git rsync shasum sqlite3 diskutil hdiutil df awk \
            find sort grep sed stat mktemp; do
  require "$tool"
done

[[ "${1:-}" == "--capture" ]] ||
  die "Explicit --capture argument required"

[[ "${DR_CAPTURE_AUTHORIZED:-}" == "YES" ]] ||
  die "Separate DR execution authorization required"

[[ -d "$REPO/.git" ]] ||
  die "Expected repository missing"

cd "$REPO"

BRANCH="$(git branch --show-current)"
[[ "$BRANCH" == "$EXPECTED_BRANCH" ]] ||
  die "Unexpected branch"

HEAD="$(git rev-parse HEAD)"
REMOTE="$(git rev-parse "origin/$EXPECTED_BRANCH")"

[[ "$HEAD" == "$REMOTE" ]] ||
  die "Local and remote-tracking HEAD differ"

[[ -z "$(git diff --cached --name-only)" ]] ||
  die "Git index contains staged changes"

# Verify the physical external drive.
[[ -d "$EXTERNAL/backups" ]] ||
  die "Rio Drive backup directory unavailable"

EXTERNAL_INFO="$(diskutil info "$EXTERNAL")"

printf '%s\n' "$EXTERNAL_INFO" |
  grep -Eq 'Mounted:[[:space:]]+Yes' ||
  die "Rio Drive is not mounted"

printf '%s\n' "$EXTERNAL_INFO" |
  grep -Eq 'File System Personality:[[:space:]]+ExFAT' ||
  die "Unexpected Rio Drive filesystem"

[[ -d "$EXPECTED_IMAGE" ]] ||
  die "Expected encrypted sparsebundle does not exist"

[[ -d "$EXPECTED_MOUNT" ]] ||
  die "Encrypted destination is not mounted"

# Verify the inner filesystem is mounted APFS.
# The enclosing sparsebundle provides encryption.
MOUNT_INFO="$(diskutil info "$EXPECTED_MOUNT")"

printf '%s\n' "$MOUNT_INFO" |
  grep -Eq 'Mounted:[[:space:]]+Yes' ||
  die "Encrypted destination is not mounted"

printf '%s\n' "$MOUNT_INFO" |
  grep -Eq 'File System Personality:[[:space:]]+APFS' ||
  die "Encrypted destination is not APFS"

# Verify encryption and mount linkage within the same
# hdiutil image record. Do not accept independent matches
# from unrelated attached images.
IMAGE_INFO="$(hdiutil info)"

printf '%s\n' "$IMAGE_INFO" |
  awk -v image="$EXPECTED_IMAGE" -v mount="$EXPECTED_MOUNT" '
    function verify_record() {
      if (seen && path_ok && encrypted && mount_ok)
        valid=1
    }

    /^image-path[[:space:]]*:/ {
      verify_record()
      seen=1
      path_ok=($0 ~ /^image-path[[:space:]]*:/ &&
               index($0, image) > 0)
      encrypted=0
      mount_ok=0
      next
    }

    seen && /^image-encrypted[[:space:]]*:/ {
      encrypted=($0 ~ /TRUE[[:space:]]*$/)
    }

    seen && index($0, mount) > 0 {
      mount_ok=1
    }

    END {
      verify_record()
      exit(valid ? 0 : 1)
    }
  ' ||
  die "Approved encrypted image and destination linkage not verified"

BACKUP_ROOT="$EXPECTED_MOUNT/backups"

case "$BACKUP_ROOT" in
  "$EXPECTED_MOUNT"/*) ;;
  *) die "Backup destination escapes encrypted volume" ;;
esac

[[ -d "$BACKUP_ROOT" ]] ||
  die "Encrypted backup directory missing"

[[ ! -L "$BACKUP_ROOT" ]] ||
  die "Encrypted backup directory must not be a symlink"

FREE_KIB="$(df -Pk "$BACKUP_ROOT" | awk 'NR==2 {print $4}')"

[[ "$FREE_KIB" =~ ^[0-9]+$ ]] ||
  die "Unable to determine free capacity"

[[ "$FREE_KIB" -ge 10485760 ]] ||
  die "Less than 10 GiB available"

[[ -f "$REPO/db/main.db" ]] ||
  die "Primary SQLite database missing"

[[ "$(sqlite3 -readonly "$REPO/db/main.db" \
  'PRAGMA quick_check;')" == "ok" ]] ||
  die "Source SQLite integrity check failed"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
SHORT_HEAD="${HEAD:0:12}"

NAME="DR_NONDESTRUCTIVE_${STAMP}_${SHORT_HEAD}"

FINAL="$BACKUP_ROOT/$NAME"
STAGING="$BACKUP_ROOT/.${NAME}.incomplete"

[[ ! -e "$FINAL" && ! -e "$STAGING" ]] ||
  die "Checkpoint destination already exists"

mkdir -m 700 "$STAGING" ||
  die "Unable to create checkpoint"

trap 'printf "DR capture interrupted; inspect %s\n" "$STAGING" >&2' ERR

mkdir -p "$STAGING/workspace" "$STAGING/database"

git status --porcelain=v1 -uall > "$STAGING/git-status.txt"
git diff --binary > "$STAGING/tracked-unstaged.patch"
git diff --cached --binary > "$STAGING/tracked-staged.patch"

git bundle create "$STAGING/repository.bundle" --all

git bundle verify "$STAGING/repository.bundle" \
  > "$STAGING/git-bundle-verification.txt" 2>&1 ||
  die "Git bundle verification failed"

rsync -a \
  --exclude='/.git/' \
  --exclude='/backups/' \
  --exclude='/db/main.db' \
  --exclude='/db/main.db-wal' \
  --exclude='/db/main.db-shm' \
  "$REPO/" "$STAGING/workspace/"

sqlite3 -readonly "$REPO/db/main.db" \
  ".backup '$STAGING/database/main.db'"

[[ "$(sqlite3 -readonly "$STAGING/database/main.db" \
  'PRAGMA integrity_check;')" == "ok" ]] ||
  die "Captured SQLite database failed integrity verification"

cat > "$STAGING/RECOVERY_MANIFEST.txt" <<MANIFEST
Classification: NONDESTRUCTIVE_ENCRYPTED_DR_CAPTURE
Timestamp: $STAMP
Repository: $REPO
Branch: $BRANCH
HEAD: $HEAD
Remote-tracking HEAD: $REMOTE
Encrypted image: $EXPECTED_IMAGE
Encrypted destination: $EXPECTED_MOUNT
Encryption boundary: AES-256 sparsebundle
Dashboard: PROTECTED_REACT_DASHBOARD
Dashboard route: /ui
Legacy dashboard restoration: PROHIBITED
Production rollback certification: NOT_ESTABLISHED
Git status: git-status.txt
Git history: repository.bundle
Workspace: workspace/
Consistent SQLite backup: database/main.db
Historical backup deletion: NONE
Git reset/clean/stash: NONE
Git commit/push: NONE
Production restart: NONE
Restore authorization: REQUIRED_SEPARATELY
Confidentiality: ENCRYPTED_DESTINATION_REQUIRED
MANIFEST

(
  cd "$STAGING"

  find . -type f \
    ! -name SHA256SUMS.txt \
    ! -name CHECKSUM_VERIFICATION.txt \
    -print0 |
    LC_ALL=C sort -z |
    while IFS= read -r -d '' file; do
      shasum -a 256 "$file"
    done > SHA256SUMS.txt

  shasum -a 256 -c SHA256SUMS.txt \
    > CHECKSUM_VERIFICATION.txt
)

mv "$STAGING" "$FINAL"
trap - ERR

printf '\nDR_CAPTURE_COMPLETE=%s\n' "$FINAL"
printf 'GIT_HEAD=%s\n' "$HEAD"
printf 'DATABASE_INTEGRITY=OK\n'
printf 'GIT_BUNDLE=VERIFIED\n'
printf 'ENCRYPTED_DESTINATION=VERIFIED\n'
printf 'HISTORICAL_BACKUPS=UNTOUCHED\n'
printf 'RESTORATION=NOT_EXECUTED\n'
