
from pathlib import Path

targets = [

    Path("public/index.html"),

    Path("public/dashboard.html"),

    Path("public/js/phase530_visible_panels_bridge.js"),

]

for path in targets:

    if not path.exists():

        continue

    text = path.read_text(encoding="utf-8")

    text = text.replace(">Task History<", ">Recent Tasks<")

    text = text.replace("> Task History <", "> Recent Tasks <")

    text = text.replace("Task History", "Recent Tasks")

    path.write_text(text, encoding="utf-8")

