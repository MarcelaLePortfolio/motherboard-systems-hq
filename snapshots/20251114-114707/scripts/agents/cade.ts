import "./utils/ensurePaths.js";
import { setCadeStatus, getCadeStatus } from "./cade_status";
import { broadcastAgentUpdate, broadcastLogUpdate } from "../../routes/eventsAgents";
import { broadcastAgentUpdate, broadcastLogUpdate } from "../../routes/eventsAgents";
import fs from "fs";

// 🧭 Cade runtime dynamic status
let cadeStatus: "online" | "busy" | "error" = "online";

export function getCadeStatus() {
  return cadeStatus;
}

// 🧠 Simulated task performer
async function performTask(task: any) {
  // Simulate a small async operation
  return new Promise((resolve) =>
    setTimeout(() => resolve(`Task ${task?.type || "unknown"} complete`), 1000)
  );
}

// ⚙️ Main runner
export async function runCadeTask(task: any) {
  try {
    cadeStatus = "busy";
    console.log("⚙️ Cade running task:", task);
  setCadeStatus("busy");
  setTimeout(() => setCadeStatus("online"), 1000);
    const result = await performTask(task);
    cadeStatus = "online";
    return result;
  } catch (err) {
    cadeStatus = "error";
    console.error("❌ Cade error:", err);
    throw err;
  }
}
