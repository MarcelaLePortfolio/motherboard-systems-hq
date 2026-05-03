from pathlib import Path

target = Path("public/index.html")
text = target.read_text()

script_tag = '<script defer src="js/phase489_panel_height_sync.js"></script>'
if script_tag in text:
    text = text.replace(script_tag, '')
    print("Removed runtime height sync script tag.")
else:
    print("No runtime script tag found (already clean).")

target.write_text(text)
