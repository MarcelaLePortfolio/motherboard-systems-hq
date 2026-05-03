from pathlib import Path

target = Path("public/index.html")
text = target.read_text()

script_tag = '  <script defer src="js/phase490_telemetry_height_probe.js"></script>\n'
anchor = '  <script defer src="js/phase61_tabs_workspace.js"></script>\n'

if script_tag not in text:
    if anchor in text:
        text = text.replace(anchor, anchor + script_tag, 1)
    else:
        raise SystemExit("Could not find phase61_tabs_workspace.js anchor")

target.write_text(text)
print("Mounted phase490_telemetry_height_probe.js")
