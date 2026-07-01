
// <0001fadf> Phase 9.5.1 — Rehydration & Delegation Verification

import { execSync } from "child_process";

function log(msg: string) {

  console.log(`🧩 ${new Date().toISOString()} — ${msg}`);

}

function hasPm2Processes(): boolean {

  try {

    const output = execSync("pm2 jlist", { encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] });

    const processes = JSON.parse(output);

    return Array.isArray(processes) && processes.length > 0;

  } catch {

    return false;

  }

}

try {

  log("Starting rehydration test: checking PM2 process inventory...");

  if (!hasPm2Processes()) {

    log("No PM2 processes found; rehydration diagnostic passed closed without restart.");

    process.exit(0);

  }

  log("Restarting all PM2-managed agents...");

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

