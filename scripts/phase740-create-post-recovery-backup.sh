
#!/bin/bash

set -e

TIMESTAMP="$(date +"%Y-%m-%dT%H-%M-%S")"

BACKUP_DIR="DISASTER_RECOVERY/phase740-post-recovery-backup-${TIMESTAMP}"

mkdir -p "${BACKUP_DIR}"

echo "📦 Creating Phase 740 post-recovery backup"

echo

echo "----- COPYING CRITICAL RECOVERY ARTIFACTS -----"

cp public/js/phase530_visible_panels_bridge.js "${BACKUP_DIR}/"

cp DISASTER_RECOVERY/phase740-served-bridge-recovery-result.md "${BACKUP_DIR}/"

cp DISASTER_RECOVERY/phase740-recent-tasks-recovery-result.md "${BACKUP_DIR}/"

cp scripts/phase740-diagnose-recent-tasks-empty.sh "${BACKUP_DIR}/" 2>/dev/null || true

cp scripts/phase740-inspect-phase530-syntax-context.sh "${BACKUP_DIR}/" 2>/dev/null || true

cp scripts/phase740-inspect-phase530-second-syntax-context.sh "${BACKUP_DIR}/" 2>/dev/null || true

cp scripts/phase740-verify-recent-tasks-recovery.sh "${BACKUP_DIR}/" 2>/dev/null || true

cp scripts/phase740-rebuild-dashboard-served-bridge.sh "${BACKUP_DIR}/" 2>/dev/null || true

echo

echo "----- WRITING RECOVERY SNAPSHOT -----"

cat > "${BACKUP_DIR}/RECOVERY_STATE.md" << SNAPSHOT

# Phase 740 Recovery Snapshot

Timestamp: ${TIMESTAMP}

Branch:

$(git branch --show-current)

HEAD:

$(git rev-parse HEAD)

Recent commits:

$(git log --oneline -n 10)

Recovery status:

- phase530 bridge syntax repaired

- served dashboard bridge rebuilt

- Recent Tasks API verified

- dashboard health verified

- no task data loss detected

- no database repair required

SNAPSHOT

echo

echo "----- CREATING ARCHIVE -----"

tar -czf "${BACKUP_DIR}.tar.gz" "${BACKUP_DIR}"

echo

echo "✅ Backup created:"

echo "${BACKUP_DIR}.tar.gz"

echo

echo "----- GIT STATUS -----"

git status

