#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 554 — SERVED SURFACE AUDIT"
echo "────────────────────────────────"

echo ""
echo "1. Confirm localhost:8080 root is serving expected dashboard markers:"
curl -s http://localhost:8080/ | grep -n "Execution Activity\|task-events-card\|mb-task-events-panel-anchor\|Phase 553" || true

echo ""
echo "2. Confirm active renderer script is loaded by served root:"
curl -s http://localhost:8080/ | grep -n "phase457_restore_task_panels.js" || true

echo ""
echo "3. Confirm served active renderer contains latest execution UI features:"
curl -s http://localhost:8080/js/phase457_restore_task_panels.js | grep -n "Selected Task\|View JSON\|Copied ✓\|mouseenter\|showJsonForEventId\|task_id:" || true

echo ""
echo "4. Confirm local file contains same active renderer markers:"
grep -n "Selected Task\|View JSON\|Copied ✓\|mouseenter\|showJsonForEventId\|task_id:" public/js/phase457_restore_task_panels.js || true

echo ""
echo "5. Confirm served root contains latest container CSS:"
curl -s http://localhost:8080/ | grep -n "Phase 549\|Phase 553\|section#task-events-card.obs-surface" || true

echo ""
echo "AUDIT COMPLETE"
