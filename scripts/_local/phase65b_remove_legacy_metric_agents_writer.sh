#!/usr/bin/env bash
set -euo pipefail

TARGET="public/js/agent-status-row.js"
BACKUP="${TARGET}.bak.phase65b_agents"

cp "$TARGET" "$BACKUP"

python3 - << 'PY'
from pathlib import Path

target = Path("public/js/agent-status-row.js")
text = target.read_text()

replacements = [
    (
"""    setMetricText(activeAgentsMetricEl, String(count));
""",
"""    // Phase 65B.6: metric-agents ownership transferred to phase64_agent_activity_wire.js
    // Legacy direct write removed intentionally.
""",
    ),
    (
"""  setMetricText(activeAgentsMetricEl, "—");
""",
"""  // Phase 65B.6: metric-agents reset ownership transferred to phase64_agent_activity_wire.js
  // Legacy direct write removed intentionally.
""",
    ),
    (
"""    setMetricText(activeAgentsMetricEl, "—");
""",
"""    // Phase 65B.6: metric-agents error-state ownership transferred to phase64_agent_activity_wire.js
    // Legacy direct write removed intentionally.
""",
    ),
]

for old, new in replacements:
    if old not in text:
        raise SystemExit(f"Expected legacy metric-agents writer not found:\\n{old!r}")
    text = text.replace(old, new, 1)

target.write_text(text)
PY

echo "Removed legacy metric-agents writers from $TARGET"
echo "Backup written to $BACKUP"
