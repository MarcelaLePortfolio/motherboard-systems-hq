// <0001faf6> Phase 9.2 — Atlas fallback task creation utility
// Allows manual or automated creation of Atlas demo tasks for validation

import { sqlite } from "../../db/client";
import { randomUUID } from "crypto";

console.log("🌍 Creating Atlas fallback task...");

try {
  const id = randomUUID();
  const type = "atlas:create";
  const status = "queued";
  const payload = JSON.stringify({ origin: "manual-fallback", timestamp: new Date().toISOString() });

  sqlite
    .prepare(
      "INSERT INTO task_events (id, type, status, agent, payload, created_at) VALUES (?, ?, ?, ?, ?, datetime('now'))"
    )
    .run(id, type, status, "Matilda", payload);

  console.log(`✅ Atlas fallback task created: ${id}`);
  console.log("Use dashboard to verify task appearance in Recent Tasks panel.");

} catch (err) {
  console.error("❌ Failed to create Atlas fallback task:", err);
}
