
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old1 = '      ? "This will create a new queued attempt using a fresh-context execution strategy. Nothing will happen unless you choose Submit."'

new1 = '      ? "This will create a new queued attempt using a fresh-context execution strategy. Please confirm this action to continue."'

old2 = '      : "This will create a new queued attempt for this task. Nothing will happen unless you choose Submit.";'

new2 = '      : "This will create a new queued attempt for this task. Please confirm this action to continue.";'

if old1 not in text:

    raise SystemExit("FRESH-CONTEXT COPY NOT FOUND")

if old2 not in text:

    raise SystemExit("STANDARD COPY NOT FOUND")

text = text.replace(old1, new1, 1)

text = text.replace(old2, new2, 1)

path.write_text(text)

print("Phase 717 modal confirmation copy refined.")

