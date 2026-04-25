from pathlib import Path

p = Path("server/worker/phase35_claim_one_pg.sql")
text = p.read_text()

old = "WHERE status = 'created'"
new = "WHERE status IN ('created','queued')"

if old not in text:
    raise SystemExit("Target status filter not found. STOP.")

p.write_text(text.replace(old, new, 1))
