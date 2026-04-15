from pathlib import Path

target = Path("public/index.html")
text = target.read_text()

script_tag = '  <script defer src="js/phase490_height_diagnostic_overlay.js"></script>\n'
if script_tag in text:
    text = text.replace(script_tag, '')
    print("Removed diagnostic overlay mount from public/index.html")
else:
    print("Diagnostic overlay mount was already absent")

target.write_text(text)
