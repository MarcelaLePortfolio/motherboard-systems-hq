from pathlib import Path

p = Path("server.mjs")
text = p.read_text()

anchor = "})(),\n      },"

if anchor not in text:
    raise SystemExit("Anchor not found. STOP.")

injection = '''})(),
        responseContext: {
          waitingOn: waitingOn || "unknown",
          agentAssignment: agentAssignment || "unassigned",
          runAgent: runAgent || "unknown",
          hasRunSummary: Boolean(runSummary)
        },
      },'''

text = text.replace(anchor, injection, 1)

p.write_text(text)
