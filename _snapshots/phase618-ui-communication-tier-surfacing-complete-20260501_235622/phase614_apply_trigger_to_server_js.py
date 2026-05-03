from pathlib import Path

p = Path("server.js")
if not p.exists():
    raise SystemExit("server.js not found")

s = p.read_text()

marker = "// PHASE614 SYSTEM TRIGGER (SAFE, REVERSIBLE)"
if marker in s:
    raise SystemExit("Phase614 trigger already present in server.js")

block = '''

// PHASE614 SYSTEM TRIGGER (SAFE, REVERSIBLE)
const SYSTEM_TRIGGER_INTERVAL_MS = 60000;

setInterval(async () => {
  try {
    await fetch("http://localhost:8080/api/delegate-task", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        kind: "system-check",
        title: "System Trigger Test",
        payload: {
          source: "system",
          intent: "baseline-trigger"
        }
      })
    });
    console.log("[phase614] system-trigger dispatched");
  } catch (err) {
    console.error("[phase614] system-trigger failed:", err.message);
  }
}, SYSTEM_TRIGGER_INTERVAL_MS);

'''

p.write_text(s.rstrip() + "\n" + block)

print("Phase614 trigger applied to server.js.")
