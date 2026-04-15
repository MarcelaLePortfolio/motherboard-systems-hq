from pathlib import Path

target = Path("public/index.html")
text = target.read_text()

script_tag = '  <script defer src="js/phase490_height_diagnostic_overlay.js"></script>\n'
anchor = '  <script defer src="js/phase61_tabs_workspace.js"></script>\n'

if script_tag not in text:
    if anchor in text:
        text = text.replace(anchor, anchor + script_tag, 1)
    else:
        raise SystemExit("Could not find mount anchor for phase61_tabs_workspace.js")

target.write_text(text)
print("Mounted phase490_height_diagnostic_overlay.js")
