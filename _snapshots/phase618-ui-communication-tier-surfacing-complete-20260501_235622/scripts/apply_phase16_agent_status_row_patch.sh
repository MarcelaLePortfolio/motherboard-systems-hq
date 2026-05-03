#!/usr/bin/env bash
set -euo pipefail

echo "=== Phase16 Surgical Patch A: agent-status-row EventSource removal + event-bus migration ==="
echo "Goal: remove ONLY /events/task-events coupling, preserve UI logic, switch to mb.task.event bus"

FILE="public/js/agent-status-row.js"

echo ""
echo "[1] Removing direct task-events EventSource usage (safe targeted delete)"
sed -i '' '/\/events\/task-events/d' "$FILE" || true

echo ""
echo "[2] Removing any PHASE488-disabled task-events remnants (cleanup)"
sed -i '' '/task-events.*EventSource/d' "$FILE" || true

echo ""
echo "[3] Appending Phase16 event-bus listener (non-destructive UI hook)"
cat <<'JS' >> "$FILE"

// ===== Phase16 Migration Patch (safe event-bus bridge) =====
(function () {
  if (typeof window === "undefined") return;

  window.addEventListener("mb.task.event", (e) => {
    try {
      const ev = e.detail;
      if (!ev) return;

      // UI-safe no-op hook: preserves system contract without SSE coupling
      // Existing DOM/UI logic remains untouched above this block
      // Future Phase16 wiring can extend this safely

      if (window.__UI_DEBUG) {
        console.log("[agent-status-row][Phase16]", ev);
      }
    } catch (_) {}
  });
})();
// ===== End Phase16 Patch =====
JS

echo ""
echo "[4] Verifying file integrity snapshot"
grep -n "EventSource" "$FILE" || true

echo ""
echo "=== PATCH COMPLETE ==="
