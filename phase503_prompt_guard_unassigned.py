from pathlib import Path

p = Path("server.mjs")
text = p.read_text()

old = 'Note: If task is unassigned, do not imply the run agent is currently executing it.'

new = 'Note: If task is unassigned, no agent is responsible for execution. Do not attribute waiting or delay to any agent in that case.'

if old not in text:
    raise SystemExit("Target note not found. STOP.")

p.write_text(text.replace(old, new, 1))
