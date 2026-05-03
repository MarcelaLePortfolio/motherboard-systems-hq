from pathlib import Path

target = Path("public/index.html")
text = target.read_text()

link_tag = '  <link rel="stylesheet" href="css/phase491_workspace_equal_height.css">\n'
anchor = '  <link rel="stylesheet" href="css/phase61_workspace_consolidation.css">\n'

if link_tag not in text:
    if anchor in text:
        text = text.replace(anchor, anchor + link_tag, 1)
    else:
        raise SystemExit("Anchor not found")

target.write_text(text)
print("Mounted phase491_workspace_equal_height.css")
