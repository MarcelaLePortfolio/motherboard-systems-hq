from pathlib import Path

p = Path("server/routes/api-tasks-postgres.mjs")
text = p.read_text()

old = "SELECT id, task_id, title, status, updated_at"
new = "SELECT id, task_id, title, status, claimed_by, updated_at"

if old not in text:
    raise SystemExit("SELECT clause not found. STOP.")

p.write_text(text.replace(old, new, 1))
