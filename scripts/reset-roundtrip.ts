// <0001faf1> Phase 6.4 — Reset + Roundtrip Validation
import { sqlite } from "../db/client";

export function resetRoundtrip() {
  try {
    console.log("🔁 Starting full system reset...");

    sqlite.exec(`
      DELETE FROM task_events;
      DELETE FROM reflection_index;
      VACUUM;
    `);

    console.log("✅ Database cleared (task_events + reflection_index).");

    const checkTasks = sqlite.prepare("SELECT COUNT(*) as c FROM task_events").get();
    const checkReflections = sqlite.prepare("SELECT COUNT(*) as c FROM reflection_index").get();

    if (checkTasks.c === 0 && checkReflections.c === 0) {
      console.log("✅ Validation passed — no orphaned entries remain.");
    } else {
      console.error("❌ Validation failed — residual data detected.");
    }

    console.log("⚙️ Reset complete. Ready for dashboard auto-refresh.");
  } catch (err) {
    console.error("❌ Reset operation failed:", err);
  }
}

if (require.main === module) {
  resetRoundtrip();
}
