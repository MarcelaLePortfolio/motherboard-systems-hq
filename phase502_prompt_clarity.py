from pathlib import Path

p = Path("server.mjs")
text = p.read_text()

old = 'Assigned to: ${agentAssignment || "unassigned"}. Run agent: ${runAgent || "unknown"}.'

new = 'Task claimed by: ${agentAssignment || "unassigned"}. Run view agent: ${runAgent || "unknown"}. Note: If task is unassigned, do not imply the run agent is currently executing it.'

if old not in text:
    raise SystemExit("Target prompt segment not found. STOP.")

p.write_text(text.replace(old, new, 1))
