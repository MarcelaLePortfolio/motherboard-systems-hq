// <0001fae1> Phase 6.1 — Live Delegation Simulation
import { sqlite } from "../../db/client";

// Helper to insert reflections & tasks
function insertReflection(content: string) {
  sqlite.prepare("INSERT INTO reflection_index (content) VALUES (?)").run(content);
}
function insertTask(agent: string, description: string) {
  sqlite
    .prepare("INSERT INTO task_events (agent, description, created_at) VALUES (?, ?, datetime('now'))")
    .run(agent, description);
}

async function simulateLiveDelegation() {
  console.log("🚀 Starting live delegation cycle: Matilda → Cade → Effie");

  insertReflection("Matilda received delegation request...");
  insertTask("Matilda", "Routing task to Cade...");
  await new Promise((r) => setTimeout(r, 2500));

  insertReflection("Cade executing assigned task...");
  insertTask("Cade", "Performing computation phase...");
  await new Promise((r) => setTimeout(r, 2500));

  insertReflection("Effie validating Cade’s results...");
  insertTask("Effie", "Running validation and reporting...");
  await new Promise((r) => setTimeout(r, 2500));

  insertReflection("Delegation round complete — reflections and OPS synced.");
  insertTask("System", "Roundtrip validation successful ✅");

  console.log("✅ Live delegation simulation completed.");
}

simulateLiveDelegation().catch((err) => console.error("❌ Delegation simulation failed:", err));
