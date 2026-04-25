from pathlib import Path

p = Path("server/worker/phase26_task_worker.mjs")
text = p.read_text()

old = "async function claimOne(c, run_id) {"
new = """async function claimOne(c, run_id) {
  const safeRunId = run_id || null;"""

if old not in text:
    raise SystemExit("Anchor not found. STOP.")

text = text.replace(old, new, 1)

old2 = "PHASE34_ENABLE_LEASE ? [run_id, owner, PHASE34_LEASE_MS] : [run_id, owner]"
new2 = "PHASE34_ENABLE_LEASE ? [safeRunId, owner, PHASE34_LEASE_MS] : [safeRunId, owner]"

if old2 not in text:
    raise SystemExit("Query args not found. STOP.")

text = text.replace(old2, new2, 1)

p.write_text(text)
