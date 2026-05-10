
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '${outcome ? `<div style="margin-top:8px;color:#d1d5db;font-size:12px;overflow-wrap:anywhere;word-break:break-word;">${outcome}</div>` : ""}'

new = '${outcome ? `<div style="margin-top:8px;color:#94a3b8;font-size:11px;overflow-wrap:anywhere;word-break:break-word;">Outcome available in Inspect logs.</div>` : ""}'

if old not in text:

    raise SystemExit("INLINE OUTCOME BLOCK NOT FOUND")

text = text.replace(old, new, 1)

path.write_text(text)

print("Inline outcome preview moved behind Inspect logs affordance.")

