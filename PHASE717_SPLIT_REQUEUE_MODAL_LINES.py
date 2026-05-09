
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '      : "This will create a new queued attempt for this task. Please confirm this action to continue.";'

new = '      : "This will create a new queued attempt for this task.\\n\\nPlease confirm this action to continue.";'

if old not in text:

    raise SystemExit("STANDARD REQUEUE COPY NOT FOUND")

text = text.replace(old, new, 1)

path.write_text(text)

print("Phase 717 requeue modal line spacing refined.")

