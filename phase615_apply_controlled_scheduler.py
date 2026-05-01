from pathlib import Path

block = r'''

// PHASE615 CONTROLLED SYSTEM SCHEDULER (DISABLED BY DEFAULT)
const SYSTEM_SCHEDULER_ENABLED = String(process.env.SYSTEM_SCHEDULER_ENABLED || "").toLowerCase() === "true";
const SYSTEM_SCHEDULER_INTERVAL_MS = Number(process.env.SYSTEM_SCHEDULER_INTERVAL_MS || 60000);

let phase615SchedulerInFlight = false;

if (SYSTEM_SCHEDULER_ENABLED) {
  console.log("[phase615] scheduler started", {
    interval_ms: SYSTEM_SCHEDULER_INTERVAL_MS
  });

  setInterval(async () => {
    if (phase615SchedulerInFlight) {
      console.log("[phase615] skipped (guard active)");
      return;
    }

    phase615SchedulerInFlight = true;

    try {
      await fetch("http://localhost:3000/api/delegate-task", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          kind: "system-check",
          title: "System Scheduler Task",
          payload: {
            source: "system",
            intent: "scheduled-check"
          }
        })
      });

      console.log("[phase615] task dispatched");
    } catch (err) {
      console.error("[phase615] scheduler failed:", err.message);
    } finally {
      phase615SchedulerInFlight = false;
    }
  }, SYSTEM_SCHEDULER_INTERVAL_MS);
} else {
  console.log("[phase615] scheduler disabled");
}

'''

for filename in ["server.js", "server.mjs"]:
    p = Path(filename)
    if not p.exists():
        continue

    s = p.read_text()
    marker = "// PHASE615 CONTROLLED SYSTEM SCHEDULER (DISABLED BY DEFAULT)"

    if marker in s:
        print(f"{filename}: scheduler block already present")
        continue

    p.write_text(s.rstrip() + "\n" + block)
    print(f"{filename}: scheduler block appended")
