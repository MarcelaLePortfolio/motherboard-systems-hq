
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''const ok = await phase717RetryModal({ title: modalTitle, message: `Submit ${label} for “${displayName}”?\\n\\nThis will create a new queued attempt for this task. Nothing will happen unless you choose Submit.`, confirmLabel: "Submit", cancelLabel: "Cancel" });'''

new = '''const detailMessage = mode === "fresh-context"

      ? "This will create a new queued attempt using a fresh-context execution strategy. Nothing will happen unless you choose Submit."

      : "This will create a new queued attempt for this task. Nothing will happen unless you choose Submit.";

    const ok = await phase717RetryModal({ title: modalTitle, message: `Submit ${label} for “${displayName}”?\\n\\n${detailMessage}`, confirmLabel: "Submit", cancelLabel: "Cancel" });'''

if old not in text:

    raise SystemExit("EXPECTED MODAL MESSAGE BLOCK NOT FOUND")

text = text.replace(old, new, 1)

path.write_text(text)

print("Retry modal behavior copy differentiated.")

