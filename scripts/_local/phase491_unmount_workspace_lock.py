from pathlib import Path

target = Path("public/index.html")
text = target.read_text()

script_tag = '  <script defer src="js/phase491_workspace_height_lock.js"></script>\n'
text = text.replace(script_tag, "")

target.write_text(text)
print("Unmounted phase491_workspace_height_lock.js")
