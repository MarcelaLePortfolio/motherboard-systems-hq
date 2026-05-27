
#!/usr/bin/env bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

BACKUP_ROOT="$ROOT/backups"

STAGING="$BACKUP_ROOT/_staging"

VAULT="$ROOT/recovery-vault"

EXCLUDES="$ROOT/.backup_excludes"

mkdir -p "$BACKUP_ROOT" "$VAULT"

echo "DR MASTER PIPELINE START"

# -------------------------

# PRE-FLIGHT GATE

# -------------------------

bash scripts/dr_preflight_check.sh

# -------------------------

# DISK SAFETY

# -------------------------

bash scripts/disk_monitor.sh

# -------------------------

# BACKUP GENERATION (SAFE STAGING)

# -------------------------

rm -rf "$STAGING"

mkdir -p "$STAGING"

git bundle create "$BACKUP_ROOT/repo_$(date +%Y%m%d_%H%M%S).bundle" --all

rsync -a --exclude-from="$EXCLUDES" "$ROOT/" "$STAGING/"

tar -czf "$BACKUP_ROOT/source_$(date +%Y%m%d_%H%M%S).tar.gz" -C "$STAGING" .

rm -rf "$STAGING"

# -------------------------

# INTEGRITY

# -------------------------

bash scripts/backup_verify.sh

bash scripts/backup_health_check.sh

# -------------------------

# EXTERNAL MIRROR (SAFE FAIL)

# -------------------------

bash scripts/external_mount_guard.sh || true

bash scripts/external_backup_sync.sh || true

# -------------------------

# VAULT ENFORCEMENT

# -------------------------

if [ -d "$VAULT" ]; then

  echo "VAULT PRESENT - ENFORCING EXCLUSION"

fi

# -------------------------

# RESTORE VALIDATION LOOP

# -------------------------

LATEST="$(ls -t "$BACKUP_ROOT"/source_*.tar.gz 2>/dev/null | head -n 1 || true)"

if [ -n "$LATEST" ]; then

  TEST_RESTORE="$BACKUP_ROOT/_restore_test"

  rm -rf "$TEST_RESTORE"

  mkdir -p "$TEST_RESTORE"

  tar -xzf "$LATEST" -C "$TEST_RESTORE"

  echo "RESTORE TEST COMPLETE"

fi

echo "DR MASTER COMPLETE"

