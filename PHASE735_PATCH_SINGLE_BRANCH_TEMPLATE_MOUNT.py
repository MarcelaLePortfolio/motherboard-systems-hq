
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

marker = 'data-phase733-single-artifact-render="true"'

marker_index = text.find(marker)

if marker_index == -1:

    raise SystemExit("single-container branch marker not found")

branch_start = text.rfind("return `", 0, marker_index)

branch_end = text.find("      `;", marker_index)

if branch_start == -1 or branch_end == -1:

    raise SystemExit("single-container branch bounds not found")

branch = text[branch_start:branch_end]

old = '''          <div

            data-phase735-visual-html-mount="true"

            data-phase735-visual-html="${encodeURIComponent(safeVisualHtml)}"

          ></div>'''

new = '''          <div data-phase735-visual-html-mount="true"></div>

          <template data-phase735-visual-html-template="true">${safeVisualHtml}</template>'''

if old not in branch:

    raise SystemExit("single-container attribute mount block not found inside branch")

patched_branch = branch.replace(old, new, 1)

text = text[:branch_start] + patched_branch + text[branch_end:]

path.write_text(text)

print("patched single-container branch to template mount")

