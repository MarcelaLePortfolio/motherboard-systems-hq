from pathlib import Path

p = Path("server/worker/phase35_claim_one_pg.sql")
text = p.read_text()

old = """WITH c AS (
  SELECT id"""

new = """WITH params AS (
  SELECT $1::text AS run_id
),
c AS (
  SELECT id"""

if old not in text:
    raise SystemExit("Anchor not found. STOP.")

p.write_text(text.replace(old, new, 1))
