
#!/usr/bin/env bash

set -euo pipefail

REPORT="PHASE740_BRIDGE_SURGICAL_RESTORE.txt"

SOURCE="_dashboard_candidate_previews/phase530-bridge-lineage/01-Motherboard_Systems_HQ__DISASTER_RECOVERY__phase740-post-recovery-backup-2026-05-25T01-01-37__phase530_visible_panels_bridge.js"

TARGET="public/js/phase530_visible_panels_bridge.js"

BACKUP_DIR="backups/phase530-bridge-before-phase740-surgical-restore"

{

  echo "===== PHASE740 BRIDGE SURGICAL RESTORE ====="

  date

  echo

  echo "===== CURRENT HEAD ====="

  git log --oneline -8

  echo

  echo "===== VERIFY SOURCE ====="

  test -f "$SOURCE"

  wc -c "$SOURCE"

  grep -ni "data-phase719-preview-artifact\|data-phase717-requeue\|data-phase717-retry-differently\|Inspect details\|Inspect trace\|Inspect logs\|renderRecent\|taskRows" "$SOURCE" | head -80 || true

  echo

  echo "===== BACKUP CURRENT BRIDGE ====="

  mkdir -p "$BACKUP_DIR"

  cp "$TARGET" "$BACKUP_DIR/phase530_visible_panels_bridge.js"

  echo "backup: $BACKUP_DIR/phase530_visible_panels_bridge.js"

  echo

  echo "===== RESTORE BRIDGE ONLY ====="

  cp "$SOURCE" "$TARGET"

  wc -c "$TARGET"

  echo

  echo "===== REBUILD DASHBOARD IMAGE ====="

  docker compose build dashboard

  echo

  echo "===== RESTART DASHBOARD ====="

  docker compose up -d dashboard

  sleep 3

  echo

  echo "===== VERIFY RUNTIME ====="

  docker compose ps

  echo

  echo "===== ROOT HEALTH ====="

  curl -I http://localhost:8080/

  echo

  echo "===== API HEALTH ====="

  curl -i http://localhost:8080/api/tasks/health

  echo

  echo "===== TASKS API ====="

  curl -sS 'http://localhost:8080/api/tasks?limit=12'

  echo

  echo "===== BRIDGE MARKER CHECK ====="

  grep -ni "data-phase719-preview-artifact\|data-phase717-requeue\|data-phase717-retry-differently\|Inspect details\|Inspect trace\|Inspect logs\|renderRecent\|taskRows" "$TARGET" | head -120 || true

  echo

  echo "===== DASHBOARD LOGS ====="

  docker logs --tail 120 motherboard-systems-hq-clean-dashboard-1 || true

  echo

  echo "===== WORKTREE ====="

  git status --short

  echo

  echo "Open: http://localhost:8080/?v=phase740-bridge-surgical"

} | tee "$REPORT"

git add restore-phase740-bridge-surgical.sh "$REPORT" "$TARGET" "$BACKUP_DIR"

git commit -m "Restore phase740 bridge surface surgically"

git push

