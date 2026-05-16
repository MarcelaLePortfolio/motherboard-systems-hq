
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''      </div>

      ${fallbackPreview}

    `;

'''

new = '''      </div>

    `;

'''

if old not in text:

    raise SystemExit("Expected fallback append block not found.")

path.write_text(text.replace(old, new, 1))

