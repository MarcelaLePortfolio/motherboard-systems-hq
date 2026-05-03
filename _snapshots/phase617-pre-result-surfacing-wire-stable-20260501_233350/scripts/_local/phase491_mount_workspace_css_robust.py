from pathlib import Path

target = Path("public/index.html")
text = target.read_text()

link_tag = '  <link rel="stylesheet" href="css/phase491_workspace_equal_height.css">\n'

if link_tag in text:
    print("phase491_workspace_equal_height.css already mounted")
else:
    if "</head>" in text:
        text = text.replace("</head>", f"{link_tag}</head>", 1)
        target.write_text(text)
        print("Mounted phase491_workspace_equal_height.css before </head>")
    else:
        raise SystemExit("Could not find </head> in public/index.html")
