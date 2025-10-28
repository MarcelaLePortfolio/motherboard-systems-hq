import { pruneOldEntries } from "../../db/client.ts";

export async function cleanupOldData() {
  console.log("<0001f9fe> 🧹 Running cleanup of old task_events & reflections...");
  pruneOldEntries(7); // default 7 days
  console.log("<0001f9fe> ✅ Cleanup complete");
}
