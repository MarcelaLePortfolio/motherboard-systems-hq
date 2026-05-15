
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

target = "    renderAgents([]);"

replacement = "    // Agent Pool intentionally preserved during refresh; /api/agents is retired."

count = text.count(target)

if count != 1:

    raise SystemExit(f"Expected exactly 1 renderAgents clearing call, found {count}. No changes applied.")

text = text.replace(target, replacement, 1)

path.write_text(text)

