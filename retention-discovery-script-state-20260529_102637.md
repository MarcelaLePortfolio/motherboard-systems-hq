# Retention Discovery Script State Inspection

## Script Exists
-rwxr-xr-x  1 marcela-dev  staff  2467 May 29 10:24 verify-retention-unit-discovery.sh

## Script Syntax

## Script Preview

#!/usr/bin/env bash

set -euo pipefail

REPORT="retention-unit-discovery-$(date +%Y%m%d_%H%M%S).md"

is_backup_file() {

  case "$1" in

    *.tar.gz|*.bundle) return 0 ;;

    *) return 1 ;;

  esac

}

scan_root() {

  root="$1"

  echo "## $root"

  echo

  if [ ! -d "$root" ]; then

    echo "exists: NO"

    echo

    return

  fi

  echo "exists: YES"

  du -sh "$root" 2>/dev/null || true

  echo

  echo "### Top-level files"

  find "$root" -maxdepth 1 -type f -print 2>/dev/null | sort | while IFS= read -r f; do

    if is_backup_file "$f"; then

      echo "$f"

    fi

  done | sed -n '1,120p'

  echo

  echo "### Top-level directories containing backup files"

  find "$root" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | sort | while IFS= read -r dir; do

    nested_count="$(find "$dir" -type f -print 2>/dev/null | while IFS= read -r f; do is_backup_file "$f" && echo "$f"; done | wc -l | tr -d ' ')"

    if [ "$nested_count" != "0" ]; then

      size="$(du -sh "$dir" 2>/dev/null | awk '{print $1}')"

      echo "$size | nested_backup_files=$nested_count | $dir"

    fi

  done

  echo

  echo "### Counts"

  top_level_files="$(find "$root" -maxdepth 1 -type f -print 2>/dev/null | while IFS= read -r f; do is_backup_file "$f" && echo "$f"; done | wc -l | tr -d ' ')"

  top_level_dirs_with_backup_files="$(find "$root" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | while IFS= read -r dir; do find "$dir" -type f -print 2>/dev/null | while IFS= read -r f; do is_backup_file "$f" && echo "$dir" && break; done; done | wc -l | tr -d ' ')"

  echo "top_level_files=$top_level_files"

  echo "top_level_dirs_with_backup_files=$top_level_dirs_with_backup_files"

  echo

}

{

  echo "# Retention Unit Discovery Verification"

  echo

  echo "This is read-only. It identifies backup units without deleting, archiving, or compressing anything."

  echo

  scan_root "/Volumes/Rio Drive/backups"

  scan_root "/Volumes/Rio Drive/Motherboard_External_Backup/snapshots"

  scan_root "$HOME/Projects/motherboard-systems-hq-clean/backups"

  echo "## Current Manager Metrics"

  cat "$HOME/motherboard-backup-system/last-run-metrics.json" 2>/dev/null || true

  echo

  echo "## Current Manager Reconciliation"

  cat "$HOME/motherboard-backup-system/reconciliation.json" 2>/dev/null || true

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" verify-retention-unit-discovery.sh

git commit -m "Verify retention unit discovery"

git push


## Recent Discovery Reports
-rw-r--r--  1 marcela-dev  staff   871B May 29 10:24 retention-unit-discovery-20260529_102414.md

## Git Status
?? .backup_excludes
?? CADE_RUNTIME_DISCOVERY.txt
?? CADE_RUNTIME_HIGH_SIGNAL_CONTENTS.txt
?? CRITICAL_RECOVERY_CORRIDORS_INSPECTION.txt
?? DASHBOARD_UI_AFTER_RUNTIME_RESTORE_DIAGNOSIS.txt
?? DR_LAUNCHER_AND_MANUAL_CHECKPOINT_INSPECTION.txt
?? EXECUTION_IMPLEMENTATION_SURFACES.txt
?? EXTERNAL_DB_BACKUP_SEARCH_BEFORE_DOCKER_RESET.txt
?? GOVERNED_ROUTE_AFTER_RUNTIME_RESTORE_SMOKE.txt
?? LATEST_SNAPSHOT_DASHBOARD_CANDIDATE_INSPECTION.txt
?? PHASE715_DASHBOARD_CANDIDATE_RESTORE.txt
?? PHASE_90_91_DASHBOARD_SURFACE_INSPECTION.txt
?? RIO_DRIVE_MANUAL_CHECKPOINT_TRANSFER.txt
?? TASK_RESPONSE_ENRICHMENT_V2.txt
?? backups/_restore_test/
?? backups/backup_index.json
?? backups/checksums_20260527_150058.txt
?? backups/checksums_20260527_150206.txt
?? backups/dr_daemon.log
?? checkpoint-phase740-bridge-restore.sh
?? compare-backend-against-rio-drive.sh
?? diagnose-dashboard-ui-after-runtime-restore.py
?? diagnose-dashboard-ui-after-runtime-restore.sh
?? diagnose-snapshots-subdir-permission.sh
?? discover-dashboard-recovery-candidates.sh
?? discover-execution-implementation-surfaces.sh
?? enrich-api-tasks-response-shape-v2.sh
?? enrich-api-tasks-response-shape.sh
?? extract-matilda-delegation-docs.sh
?? inspect-critical-recovery-corridors.sh
?? inspect-dr-launcher-and-create-manual-checkpoint.sh
?? inspect-governed-execution-lineage.sh
?? inspect-latest-snapshot-dashboard-candidate.sh
?? inspect-latest-source-backups-for-db-assets.sh
?? inspect-phase-90-and-91-dashboard-surfaces.sh
?? inspect-retention-discovery-script-state.sh
?? inspect-rio-drive-disaster-backups-v2.sh
?? logs/disaster-backup.err.log
?? logs/disaster-backup.out.log
?? migrate-task-mutation-schema.sh
?? missing-controls-search.txt
?? missing-task-card-controls-filelist.tmp
?? missing-task-card-controls-inspection-20260528_203345.md
?? missing-task-card-controls-inspection-20260528_205837.md
?? missing-task-card-controls-inspection-20260528_205952.md
?? missing-task-card-controls-inspection-20260528_210120.md
?? missing-task-card-controls-inspection-20260528_211506.md
?? missing-task-card-controls-inspection-20260528_212052.md
?? move-manual-checkpoint-to-rio-drive.sh
?? patch-complete-task-run-id-handoff.sh
?? record-route-level-smoke-failure-and-clean.sh
?? retention-discovery-script-state-20260529_102637.md
?? retention-unit-discovery-20260529_102414.md
?? scripts/dr
?? scripts/dr_autonomous_wrapper.sh
?? scripts/dr_daemon.sh
?? scripts/dr_daemon_self_healing.sh
?? scripts/dr_watchdog.sh
?? scripts/offsite_r2_sync.sh
?? scripts/retention_engine.sh
?? scripts/storage_guard.sh
?? scripts/storage_monitor.sh
?? scripts/storage_policy.sh
?? scripts/vault_layer.sh
?? search-external-db-backups-before-docker-reset.sh
?? smoke-current-task-mutations-with-runid.sh
?? smoke-governed-route-after-runtime-restore.sh
?? snapshots-subdir-permission-diagnosis-20260528_234421.md
?? verify-retention-unit-discovery.sh
