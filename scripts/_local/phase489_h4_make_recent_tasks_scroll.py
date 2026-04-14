from pathlib import Path

target = Path("public/index.html")
text = target.read_text()

style_id = "phase489-recent-tasks-scroll"

block = """
<style id="phase489-recent-tasks-scroll">
  [data-phase61-shell="recent"] {
    min-height: 0 !important;
  }

  [data-phase61-list="recent"] {
    max-height: 18rem !important;
    overflow: auto !important;
    padding-right: 0.15rem;
  }
</style>
"""

if style_id not in text:
    insert_anchor = '  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.2/dist/chart.umd.js"></script>\n'
    if insert_anchor in text:
        text = text.replace(insert_anchor, block + "\n" + insert_anchor, 1)
    else:
        raise SystemExit("Could not find script anchor in public/index.html")

target.write_text(text)
print("Patched public/index.html to make Recent Tasks scroll.")
