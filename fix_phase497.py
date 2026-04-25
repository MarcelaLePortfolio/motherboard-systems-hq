from pathlib import Path

p = Path("server.mjs")
text = p.read_text()

text = text.replace("\n\nmeta: {", "\n      meta: {")
text = text.replace("})()\n      },", "})(),\n      },")

p.write_text(text)
