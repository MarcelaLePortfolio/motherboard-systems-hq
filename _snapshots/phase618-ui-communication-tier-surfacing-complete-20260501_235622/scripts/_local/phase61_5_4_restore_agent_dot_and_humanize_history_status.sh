#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

TARGET_HTML="public/dashboard.html"
TARGET_AGENT_JS="public/js/agent-status-row.js"
TARGET_RECENT_JS="public/js/phase61_recent_history_wire.js"

cp "$TARGET_HTML" "${TARGET_HTML}.bak.phase61_5_4"
cp "$TARGET_AGENT_JS" "${TARGET_AGENT_JS}.bak.phase61_5_4"
cp "$TARGET_RECENT_JS" "${TARGET_RECENT_JS}.bak.phase61_5_4"

python3 - << 'PY'
from pathlib import Path

# --- remove duplicate script load (bundle already includes it) ---
html_path = Path("public/dashboard.html")
html = html_path.read_text()
html = html.replace('<script src="js/agent-status-row.js"></script>', '')
html_path.write_text(html)

# --- clean up status text for recent/history ---
recent_path = Path("public/js/phase61_recent_history_wire.js")
recent = recent_path.read_text()

recent = recent.replace('statusEl.textContent = `Loading ${RECENT_ENDPOINT} …`;', 'statusEl.textContent = "Loading recent tasks…";')
recent = recent.replace('statusEl.textContent = `Loading ${HISTORY_ENDPOINT} …`;', 'statusEl.textContent = "Loading task history…";')
recent = recent.replace('statusEl.textContent = "No recent tasks returned";', 'statusEl.textContent = "No recent tasks returned.";')
recent = recent.replace('statusEl.textContent = "No task history returned";', 'statusEl.textContent = "No task history returned.";')

recent_path.write_text(recent)

# --- force visible agent dot ---
agent_path = Path("public/js/agent-status-row.js")
agent = agent_path.read_text()

agent = agent.replace(
'indicator.bar.className = "inline-block w-2 h-2 rounded-full shrink-0";',
'''
indicator.bar.className = "inline-block shrink-0";
indicator.bar.style.width = "8px";
indicator.bar.style.height = "8px";
indicator.bar.style.minWidth = "8px";
indicator.bar.style.minHeight = "8px";
indicator.bar.style.borderRadius = "999px";
indicator.bar.style.marginRight = "8px";
'''
)

agent_path.write_text(agent)
PY

echo "✔ Phase 61.5.4 patch applied"
