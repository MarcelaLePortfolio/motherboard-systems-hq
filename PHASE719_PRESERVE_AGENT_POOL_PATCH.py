
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''  async function refresh() {

    // Phase 719: /api/agents is retired in this runtime.

    // Stale fetch disabled to preserve console clarity.

    renderAgents([]);

    try {

'''

new = '''  async function refresh() {

    // Phase 719: /api/agents is retired in this runtime.

    // Preserve existing Agent Pool DOM instead of clearing it on every refresh.

    try {

'''

if old not in text:

    raise SystemExit("Target refresh renderAgents block not found. No changes applied.")

text = text.replace(old, new, 1)

path.write_text(text)

