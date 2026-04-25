from pathlib import Path

p = Path("public/js/phase61_recent_history_wire.js")
text = p.read_text()

old = 'agent: row?.agent || payload?.agent || payload?.target || row?.actor || row?.owner || "unassigned",'
new = 'agent: row?.claimed_by || row?.claimedBy || payload?.claimed_by || payload?.claimedBy || row?.agent || payload?.agent || payload?.target || row?.actor || row?.owner || "unassigned",'

if old not in text:
    raise SystemExit("Recent task agent mapping not found. STOP.")

p.write_text(text.replace(old, new, 1))
