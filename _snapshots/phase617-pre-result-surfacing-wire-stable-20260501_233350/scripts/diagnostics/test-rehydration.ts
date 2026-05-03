// <0001fadf> Phase 9.5.1 — Rehydration & Delegation Verification
import { execSync } from "child_process";

function log(msg: string) {
  console.log(`🧩 ${new Date().toISOString()} — ${msg}`);
}

try {
  log("Starting rehydration test: restarting all agents...");
  execSync("pm2 restart all", { stdio: "inherit" });

  log("Sleeping 5s for agents to settle...");
  execSync("sleep 5");

  log("Listing active processes...");
  execSync("pm2 list", { stdio: "inherit" });

  log("Verifying reflections heartbeat...");
  execSync("grep '�� Atlas heartbeat' logs/reflections/atlas.log | tail -n 3", { stdio: "inherit" });

  log("Triggering Matilda → Cade → Atlas delegation test...");
  execSync(
    "curl -s -X POST http://localhost:3001/matilda -H 'Content-Type: application/json' -d '{\"message\":\"Matilda, re-delegate a simple status check through Cade to Atlas.\"}'",
    { stdio: "inherit" }
  );

  log("✅ Rehydration and delegation validation sequence complete.");
} catch (err) {
  console.error("❌ Rehydration test encountered an error:", err);
  process.exit(1);
}
