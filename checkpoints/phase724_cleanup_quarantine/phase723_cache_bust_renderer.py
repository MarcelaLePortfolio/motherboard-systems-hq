
from pathlib import Path

targets = [

    Path("public/index.html"),

    Path("public/dashboard.html"),

]

old_values = [

    'src="js/phase530_visible_panels_bridge.js"',

    'src="/js/phase530_visible_panels_bridge.js"',

]

new_relative = 'src="js/phase530_visible_panels_bridge.js?v=phase723-visual-wrapper"'

new_absolute = 'src="/js/phase530_visible_panels_bridge.js?v=phase723-visual-wrapper"'

changed = []

for path in targets:

    if not path.exists():

        continue

    text = path.read_text()

    updated = text

    updated = updated.replace('src="js/phase530_visible_panels_bridge.js?v=phase723-visual-wrapper"', new_relative)

    updated = updated.replace('src="/js/phase530_visible_panels_bridge.js?v=phase723-visual-wrapper"', new_absolute)

    updated = updated.replace('src="js/phase530_visible_panels_bridge.js"', new_relative)

    updated = updated.replace('src="/js/phase530_visible_panels_bridge.js"', new_absolute)

    if updated != text:

        path.write_text(updated)

        changed.append(str(path))

if not changed:

    raise SystemExit("No renderer script references changed. Check script path manually.")

print("Updated renderer script cache-bust references:")

for item in changed:

    print("-", item)

