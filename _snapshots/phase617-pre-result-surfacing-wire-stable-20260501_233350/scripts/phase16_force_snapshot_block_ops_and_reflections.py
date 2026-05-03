from pathlib import Path
import re, sys

p = Path("server/optional-sse.mjs")
s = p.read_text()

# Replace the entire snapshot-on-connect block (from marker to catch) with a clean sibling version.
pat = re.compile(
    r'^[ \t]*//\s*PHASE16_OPTIONAL_SSE_SNAPSHOT_ON_CONNECT\s*\n'
    r'(?:^[ \t]*//.*\n)*'
    r'^[ \t]*try\s*\{\n'
    r'(?:.*\n)*?'
    r'^[ \t]*\}\s*catch\s*\(_\)\s*\{\s*\}\s*\n',
    re.M
)

m = pat.search(s)
if not m:
    print("❌ could not find snapshot-on-connect block to rewrite")
    sys.exit(2)

replacement = """\
        // PHASE16_OPTIONAL_SSE_SNAPSHOT_ON_CONNECT
        // Send an immediate state snapshot so the dashboard can paint instantly.
        try {
          if (kind === "ops" && globalThis.__OPS_STATE) {
            writeEvent(res, { event: "ops.state", data: globalThis.__OPS_STATE });
          }
          if (kind === "reflections") {
            const snap = globalThis.__REFLECTIONS_STATE || { items: [], lastAt: null };
            writeEvent(res, { event: "reflections.state", data: snap });
          }
        } catch (_) {}
"""

s2 = s[:m.start()] + replacement + s[m.end():]
p.write_text(s2)
print("✅ forced snapshot-on-connect block to ops+reflections siblings")
