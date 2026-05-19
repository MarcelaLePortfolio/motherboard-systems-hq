
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = "      const safeVisualHtml = phase723SanitizeVisualArtifactHtml(extractedVisual.visualHtml);"

new = '''      const decodedVisualHtml = phase733NormalizePreviewTransportText(extractedVisual.visualHtml)

        .replace(/\\\\\\\\n/g, "\\n")

        .replace(/\\\\\\\\\\"/g, '"')

        .replace(/\\\\\\\\'/g, "'");

      const safeVisualHtml = phase723SanitizeVisualArtifactHtml(decodedVisualHtml);'''

if old not in text:

    raise SystemExit("safe visual html line not found")

path.write_text(text.replace(old, new, 1))

print("patched visual html transport decode")

