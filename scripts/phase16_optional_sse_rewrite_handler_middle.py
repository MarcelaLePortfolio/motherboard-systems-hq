from pathlib import Path
import re, sys

p = Path("server/optional-sse.mjs")
s = p.read_text()

# Locate the hello writeEvent(...) block in handler()
hello_pat = re.compile(
    r'(// Immediate hello so clients receive bytes instantly\s*\n\s*writeEvent\(res,\s*\{\s*\n\s*event:\s*"hello",.*?\n\s*\}\);\s*)',
    re.S
)
m1 = hello_pat.search(s)
if not m1:
    print("❌ Could not find the hello writeEvent block inside handler()")
    sys.exit(2)

# Locate the Keepalive section that follows
ka_pat = re.compile(r'(\n\s*// Keepalive comment.*)', re.S)
m2 = ka_pat.search(s, m1.end())
if not m2:
    print("❌ Could not find the // Keepalive comment section after hello")
    sys.exit(2)

middle = """
\n
      // PHASE16_OPTIONAL_SSE_SNAPSHOT_ON_CONNECT
      // Send an immediate state snapshot so the dashboard can paint instantly.
      // (Only OPS has a defined global state today.)
      try {
        if (kind === "ops" && globalThis.__OPS_STATE) {
          writeEvent(res, { event: "ops.state", data: globalThis.__OPS_STATE });
        }
      } catch (_) {}

      // PHASE16_OPTIONAL_SSE_ONCE_DEFINED
      // If ?once=1, end immediately after hello/snapshot for clean curl smoke tests.
      let once = false;
      try {
        const url = new URL(req.originalUrl || req.url || "/", "http://localhost");
        once = url.searchParams.get("once") === "1";
      } catch (_) {}
      if (once) {
        setTimeout(() => { try { res.end(); } catch (_) {} }, 25);
        return;
      }
"""

# Replace everything between end-of-hello block and start of keepalive block
s2 = s[:m1.end()] + middle + s[m2.start():]
p.write_text(s2)

print("✅ rewrote handler() middle (snapshot + clean once) and removed broken fragments")
