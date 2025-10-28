import { pruneOldEntries, pruneReflections } from "../../db/client.ts";
import { db } from "../../db/client.ts";

export async function cleanupOldData() {
  console.log("<0001fa9b> 🧹 Running scheduled cleanup of old entries...");
  pruneOldEntries(7);
  pruneReflections(7);

  const stmt = db.prepare(`
    INSERT INTO task_events (id, type, status, actor, payload, result, created_at)
    VALUES (@id, 'auto_prune', 'success', 'system', '{}', 'Old entries cleaned', datetime('now'))
  `);
  stmt.run({ id: crypto.randomUUID() });

  console.log("<0001fa9b> ✅ Cleanup complete — old entries pruned and logged.");
}
