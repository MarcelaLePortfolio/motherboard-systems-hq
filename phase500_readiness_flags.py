from pathlib import Path

p = Path("server.mjs")
text = p.read_text()

anchor = '''        responseContext: {
          waitingOn: waitingOn || "unknown",
          agentAssignment: agentAssignment || "unassigned",
          runAgent: runAgent || "unknown",
          hasRunSummary: Boolean(runSummary)
        },'''

replacement = '''        responseContext: {
          waitingOn: waitingOn || "unknown",
          agentAssignment: agentAssignment || "unassigned",
          runAgent: runAgent || "unknown",
          hasRunSummary: Boolean(runSummary),
          isBlocked: Boolean(waitingOn),
          isAssigned: Boolean(agentAssignment),
          hasRunAgent: Boolean(runAgent)
        },'''

if anchor not in text:
    raise SystemExit("Anchor not found. STOP.")

p.write_text(text.replace(anchor, replacement, 1))
