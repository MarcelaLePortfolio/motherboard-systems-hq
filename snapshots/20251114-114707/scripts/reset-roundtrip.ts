// <0001faf3> Phase 6.4 — Reset + Roundtrip Validation (ESM Compatible)
import { fileURLToPath } from "url";
import { dirname } from "path";

export function resetRoundtrip() {
  try {
    console.log("🔁 Starting full system reset...");

    db.exec(`
      DELETE FROM task_events;
      DELETE FROM reflection_index;
      VACUUM;
    `);

    console.log("✅ Database cleared (task_events + reflection_index).");

    const checkTasks = db.prepare("SELECT COUNT(*) as c FROM task_events").get();
    const checkReflections = db.prepare("SELECT COUNT(*) as c FROM reflection_index").get();

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

// ESM-compatible main module execution
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
if (process.argv[1] === __filename) {
  resetRoundtrip();
}
