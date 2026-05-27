// ./scripts/agents/ops.ts
import { setInterval } from "timers";
import fs from "fs";
import path from "path";

const OPS_INTERVAL_MS=3000;
const logPath = path.join(process.cwd(), "logs", "ops.log");

function log(message: string){
  const timestamp = new Date().toISOString();
  fs.appendFileSync(logPath, `[${timestamp}] ${message}\n`, "utf8");
  console.log(`[OPS] ${message}`);
}

function processOps(){
  const task = { id: Math.floor(Math.random()*1000), type: "demo-task" };
  log(`Processing task #${task.id} of type "${task.type}"`);
  if(Math.random() > 0.95) log(`⚠️ Failed to process task #${task.id}`);
}

function emitOpsSSE(){
  const ssePath = path.join(process.cwd(), "public/tmp/ops.json");
  const status = { timestamp: new Date().toISOString(), activeTasks: Math.floor(Math.random()*5) };
  fs.writeFileSync(ssePath, JSON.stringify(status, null, 2), "utf8");
}

log("Ops agent starting...");
setInterval(()=>{
  processOps();
  emitOpsSSE();
}, OPS_INTERVAL_MS);
