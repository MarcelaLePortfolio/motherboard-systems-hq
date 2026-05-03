import fs from "fs";

import path from "path";
import { sqlite } from "../../db/client";

let pushReflection;
(async () => { ({ pushReflection } = await import("../utils/reflection-push.js")); })();


const OUT_PATH = path.join(process.cwd(), "public", "delegation_success.html");

function executeDelegation(task: any) {
  console.log(`🧠 Cade executing delegation ID ${task.id}: ${task.description}`);

  // Simulate action by writing confirmation file
  const html = `<html><body><h1>${task.description}</h1></body></html>`;
  fs.writeFileSync(OUT_PATH, html, "utf8");

  // Mark as completed
  sqlite.prepare(
    "UPDATE task_events SET status = 'completed' WHERE id = ?"
  ).run(task.id);

  console.log(`✅ Delegation ID ${task.id} completed → ${OUT_PATH}`);


  pushReflection("🤖 Cade completed a delegation task successfully.");
}


function checkPendingDelegations() {
  const pending = sqlite.prepare(
    "SELECT id, description FROM task_events WHERE event_type = 'delegation' AND status = 'pending'"
  ).all();

  for (const task of pending) executeDelegation(task);
}

// Run loop every 10 seconds
console.log("🚀 Cade Delegation Watcher active...");
setInterval(checkPendingDelegations, 10000);
