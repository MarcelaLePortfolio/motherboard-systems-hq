#!/usr/bin/env python3
from pathlib import Path
import re
import subprocess
import sys

target = Path("public/js/agent-status-row.js")
text = target.read_text()
original = text

pattern = re.compile(
    r"""(\s*if \(latencyNode\) \{\n\s*// Phase 65C: metric-latency ownership transferred to telemetry reducer\n\s*// Legacy direct write removed intentionally\.\n\s*\})\n\s*\}\n\s*\};""",
    re.MULTILINE,
)

replacement = r"""\1
    };"""

text, count = pattern.subn(replacement, text, count=1)

if count != 1:
    print("ERROR: expected malformed render block not found exactly once", file=sys.stderr)
    sys.exit(1)

if text == original:
    print("ERROR: no change applied", file=sys.stderr)
    sys.exit(1)

target.write_text(text)

subprocess.run(["npm", "run", "build:dashboard-bundle"], check=True)
print("Fixed render syntax in public/js/agent-status-row.js and rebuilt public/bundle.js")
