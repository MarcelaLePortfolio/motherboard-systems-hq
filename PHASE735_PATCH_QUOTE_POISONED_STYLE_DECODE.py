
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''    const source = phase733NormalizePreviewTransportText(html || "")

      .replace(/\\\\\\\\n/g, "\\n")

      .replace(/\\\\\\\\\\"/g, '"')

      .replace(/\\\\\\\\'/g, "'");'''

new = '''    const source = phase733NormalizePreviewTransportText(html || "")

      .replace(/\\\\\\\\n/g, "\\n")

      .replace(/\\\\\\\\\\"/g, '"')

      .replace(/\\\\\\\\'/g, "'")

      .replace(/style="\\\\+"/g, 'style="')

      .replace(/;\\\\+"/g, ';')

      .replace(/\\\\+"=/g, '=');'''

if old not in text:

    raise SystemExit("decode helper source block not found")

path.write_text(text.replace(old, new, 1))

print("patched quote-poisoned style decode")

