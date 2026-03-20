#!/usr/bin/env python3
from pathlib import Path
import sys

target = Path("public/js/agent-status-row.js")
text = target.read_text()
original = text

old = "  const successNode = document.getElementById('metric-success');"
new = "  const successNode = null; // Phase 62B: success writer neutralized; telemetry module remains sole writer"

if old not in text:
    print("ERROR: successNode binding not found in public/js/agent-status-row.js", file=sys.stderr)
    sys.exit(1)

text = text.replace(old, new, 1)

guard_marker = "        if (terminalSuccessTypes.has(eventType)) completedCount += 1;\n        if (terminalFailureTypes.has(eventType)) failedCount += 1;"
guard_replacement = "        if (terminalSuccessTypes.has(eventType)) completedCount += 1; // observer-only state retained\n        if (terminalFailureTypes.has(eventType)) failedCount += 1; // observer-only state retained"

if guard_marker not in text:
    print("ERROR: terminal counter block not found in public/js/agent-status-row.js", file=sys.stderr)
    sys.exit(1)

text = text.replace(guard_marker, guard_replacement, 1)

if text == original:
    print("ERROR: no safe patch was applied", file=sys.stderr)
    sys.exit(1)

target.write_text(text)
print("Neutralized success metric writer path in public/js/agent-status-row.js")
