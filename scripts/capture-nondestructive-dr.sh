#!/usr/bin/env bash
set -euo pipefail
umask 077

# NON-DESTRUCTIVE DISASTER RECOVERY CAPTURE
# Execution requires separate operator authorization.
# Never run automatically from deployment or startup scripts.

EXPECTED_BRANCH="feature/support-source-references-runtime"
REPO="/Users/marcela-dev/Projects/motherboard-systems-hq-clean"
BACKUP_ROOT="/Volumes/Rio Drive/backups"

die() {
  printf 'DR ERROR: %s\n' "$*" >&2
  exit 1
}

require() {
  command -v "$1" >/dev/null 2>&1 || die "Missing dependency: $1"
}

for tool in git rsync tar shasum sqlite3 diskutil df awk mktemp; do
  require "$tool"
done

[[ "${1:-}" == "--capture" ]] ||
  die "Explicit --capture argument required"

[[ "${DR_CAPTURE_AUTHORIZED:-}" == "YES" ]] ||
  die "DR_CAPTURE_AUTHORIZED=YES required"

[[ -d "$REPO/.git" ]] ||
  die "Expected repository not found"

cd "$REPO"

BRANCH="$(git branch --show-current)"
[[ "$BRANCH" == "$EXPECTED_BRANCH" ]] ||
  die "Unexpected branch: $BRANCH"

HEAD="$(git rev-parse HEAD)"
REMOTE="$(git rev-parse "origin/$EXPECTED_BRANCH")"

[[ "$HEAD" == "$REMOTE" ]] ||
  die "Local and remote-tracking HEAD differ"

[[ -z "$(git diff --cached --name-only)" ]] ||
  die "Git index contains staged changes"

[[ -d "$BACKUP_ROOT" ]] ||
  die "Backup destination unavailable"

MOUNT="$(diskutil info "/Volumes/Rio Drive" 2>/dev/null || true)"
printf '%s\n' "$MOUNT" | grep -q 'Mounted: *Yes' ||
  die "Rio Drive mount not verified"

FREE_KIB="$(df -Pk "$BACKUP_ROOT" | awk 'NR==2 {print $4}')"
[[ "$FREE_KIB" =~ ^[0-9]+$ ]] ||
  die "Unable to determine free space"

[[ "$FREE_KIB" -ge 10485760 ]] ||
  die "Less than 10 GiB available"

[[ -f db/main.db ]] ||
  die "Primary SQLite database missing"

[[ "$(sqlite3 -readonly db/main.db 'PRAGMA quick_check;')" == "ok" ]] ||
  die "Source SQLite integrity check failed"

# Capture confidentiality:
# - Archive remains on the operator's local external drive.
# - Restrictive permissions are requested.
# - No backup contents are committed or pushed.
# - Credentials are not printed in the manifest.
#
# IMPORTANT: Rio Drive uses ExFAT and does not enforce Unix permissions.
# Require an encrypted destination before any capture containing secrets.

[[ "${DR_ENCRYPTED_DESTINATION_CONFIRMED:-}" == "YES" ]] ||
  die "Encrypted destination confirmation required"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
SHORT_HEAD="${HEAD:0:12}"
NAME="DR_NONDESTRUCTIVE_${STAMP}_${SHORT_HEAD}"
FINAL="$BACKUP_ROOT/$NAME"
STAGING="$BACKUP_ROOT/.${NAME}.incomplete"

[[ ! -e "$FINAL" && ! -e "$STAGING" ]] ||
  die "Checkpoint destination already exists"

mkdir -m 700 "$STAGING" ||
  die "Unable to create checkpoint"

# Never delete staging automatically: preserve partial evidence
# for manual review if a capture fails.
trap 'printf "DR capture interrupted; inspect %s\n" "$STAGING" >&2' ERR

mkdir -p "$STAGING/workspace" "$STAGING/database"

git status --porcelain=v1 -uall > "$STAGING/git-status.txt"
git diff --binary > "$STAGING/tracked-unstaged.patch"
git diff --cached --binary > "$STAGING/tracked-staged.patch"

git bundle create "$STAGING/repository.bundle" --all
git bundle verify "$STAGING/repository.bundle" \
  > "$STAGING/git-bundle-verification.txt" 2>&1 ||
  die "Git bundle verification failed"

# Exclude nested historical backups and Git metadata.
# All other workspace files, including untracked files,
# are preserved. SQLite live database files are captured
# separately using SQLite's backup mechanism.
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
Classification: NONDESTRUCTIVE_DR_CAPTURE
Timestamp: $STAMP
Repository: $REPO
Branch: $BRANCH
HEAD: $HEAD
Remote-tracking HEAD: $REMOTE
Dashboard: PROTECTED_REACT_DASHBOARD
Dashboard route: /ui
Legacy dashboard restore: PROHIBITED
Production rollback certification: NOT_ESTABLISHED
Working-tree status: git-status.txt
Git history: repository.bundle
Workspace: workspace/
Consistent SQLite backup: database/main.db
Historical backup deletion: NONE
Git reset/clean/stash: NONE
Git commit/push: NONE
Production restart: NONE
Restore authorization: REQUIRED_SEPARATELY
Confidentiality: CONTAINS_POTENTIALLY_SENSITIVE_DATA
MANIFEST

# Create checksums without embedding the checksum file itself.
(
  cd "$STAGING"
  find . -type f ! -name SHA256SUMS.txt -print0 |
    LC_ALL=C sort -z |
    while IFS= read -r -d '' file; do
      shasum -a 256 "$file"
    done > SHA256SUMS.txt

  shasum -a 256 -c SHA256SUMS.txt \
    > CHECKSUM_VERIFICATION.txt
)

# Publish only after verification.
mv "$STAGING" "$FINAL"
trap - ERR

printf '\nDR_CAPTURE_COMPLETE=%s\n' "$FINAL"
printf 'GIT_HEAD=%s\n' "$HEAD"
printf 'DATABASE_INTEGRITY=OK\n'
printf 'GIT_BUNDLE=VERIFIED\n'
printf 'HISTORICAL_BACKUPS=UNTOUCHED\n'
printf 'RESTORATION=NOT_EXECUTED\n'
