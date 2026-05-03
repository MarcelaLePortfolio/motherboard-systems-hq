from pathlib import Path
import re, sys

p = Path("server/optional-sse.mjs")
s = p.read_text()

if "PHASE16_WRITE_EVENT_FIX_SWAPPED" in s:
    print("✅ already patched (PHASE16_WRITE_EVENT_FIX_SWAPPED present)")
    sys.exit(0)

# Insert right after the existing normalize block (after the {type,payload} mapping)
anchor = r'if \(evt && typeof evt === "object" && typeof evt\.type === "string" && event == null\) \{\n\s*event = evt\.type;\n\s*data = \(evt\.payload !== undefined \? evt\.payload : evt\);\n\s*\}\n'

m = re.search(anchor, s)
if not m:
    print("❌ could not find the existing {type,payload} normalize block to extend")
    sys.exit(2)

ins = """
  // PHASE16_WRITE_EVENT_FIX_SWAPPED
  // Some callers accidentally pass { event: <msgObject>, data: <msgTypeString> }.
  // If so, swap/normalize so SSE "event:" is a string and "data:" is the payload.
  if (event && typeof event === "object" && typeof data === "string") {
    const maybe = event;
    if (typeof maybe.type === "string" && data === maybe.type) {
      event = maybe.type;
      data = (maybe.payload !== undefined ? maybe.payload : maybe);
    } else if (typeof maybe.type === "string" && data.includes(".") && data === maybe.type) {
      event = maybe.type;
      data = (maybe.payload !== undefined ? maybe.payload : maybe);
    } else if (typeof maybe.type === "string" && data.includes(".")) {
      // If data *looks* like an event name, treat it as the event anyway.
      event = data;
      data = (maybe.payload !== undefined ? maybe.payload : maybe);
    }
  }
"""

s2 = s[:m.end()] + ins + s[m.end():]
p.write_text(s2)
print("✅ patched server/optional-sse.mjs (fix swapped event/data -> no more [object Object])")
