#!/usr/bin/env bash
set -euo pipefail

TARGET="public/js/agent-status-row.js"
BACKUP="${TARGET}.bak.phase65b"

cp "$TARGET" "$BACKUP"

python3 - << 'PY'
from pathlib import Path
target = Path("public/js/agent-status-row.js")
text = target.read_text()

old = """      tasksNode.textContent = String(runningTaskIds.size);
"""
new = """      // Phase 65B.2: metric-tasks ownership transferred to telemetry reducer
      // Legacy direct write removed intentionally.
"""

if old not in text:
    raise SystemExit("Expected legacy metric-tasks writer not found; aborting.")

text = text.replace(old, new, 1)
target.write_text(text)
PY

echo "Removed legacy metric-tasks writer from $TARGET"
echo "Backup written to $BACKUP"
