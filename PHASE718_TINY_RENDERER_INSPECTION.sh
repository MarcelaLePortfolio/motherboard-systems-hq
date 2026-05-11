
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

echo "Target: $TARGET"

echo ""

echo "[1] Retry controls window"

grep -nE "Retry differently|Requeue|delegate-task" "$TARGET" | head -5 || true

echo ""

echo "[2] Lifecycle window"

grep -nE "lifecycle|Recent Tasks|task_events|task-events" "$TARGET" | head -5 || true

echo ""

echo "[3] Lineage fields window"

grep -nE "retry_of_task_id|execution_mode|strategy|explanation_preview" "$TARGET" | head -10 || true

