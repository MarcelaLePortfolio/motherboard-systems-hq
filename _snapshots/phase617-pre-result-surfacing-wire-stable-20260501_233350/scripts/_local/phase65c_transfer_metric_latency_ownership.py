from pathlib import Path
import re
import sys

path = Path("public/js/agent-status-row.js")
text = path.read_text(encoding="utf-8")

pattern = re.compile(
    r"""
    (\n\s*if\s*\(latencyNode\)\s*\{\n)
    (?P<body>.*?)
    (\s*\}\n)
    """,
    re.VERBOSE | re.DOTALL,
)

match = None
for m in pattern.finditer(text):
    body = m.group("body")
    if "latencyNode.textContent" in body and "recentDurationsMs" in body:
        match = m
        break

if not match:
    print("ERROR: could not find latencyNode render block", file=sys.stderr)
    sys.exit(1)

replacement = """
    if (latencyNode) {
      // Phase 65C: metric-latency ownership transferred to telemetry reducer
      // Legacy direct write removed intentionally.
    }
"""

text2 = text[:match.start()] + replacement + text[match.end():]

if text2 == text:
    print("ERROR: no change made", file=sys.stderr)
    sys.exit(1)

path.write_text(text2, encoding="utf-8")
print("patched public/js/agent-status-row.js")
