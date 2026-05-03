from pathlib import Path

p = Path("server/worker/phase26_task_worker.mjs")
s = p.read_text()

marker = "const task ="

injection = """
    // --- Phase 583: retry visibility (non-invasive) ---
    try {
      const payload = task.payload || {};
      if (payload && typeof payload === "object") {
        const retryMode = payload.retry_mode || payload.execution_mode || "none";
        const retryOf = payload.retry_of_task_id || "none";

        console.log("[worker][retry-context]", {
          task_id: task.task_id,
          retry_mode: retryMode,
          retry_of_task_id: retryOf
        });
      }
    } catch (err) {
      console.warn("[worker][retry-context] failed to inspect payload");
    }
"""

if injection.strip() not in s:
    s = s.replace(marker, injection + "\n" + marker)
    p.write_text(s)
    print("✅ Worker retry visibility injected")
else:
    print("⚠️ Already injected")
