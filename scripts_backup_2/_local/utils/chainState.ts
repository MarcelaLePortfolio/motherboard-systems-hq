 
import fs from "fs";
import path from "path";
import lockfile from "proper-lockfile";

const statePath = path.resolve(process.cwd(), "memory", "agent_chain_state.json");

export async function readChainState(): Promise<any | null> {
  try {
    const release = await lockfile.lock(statePath);
    const data = fs.readFileSync(statePath, "utf8");
    release();
    return JSON.parse(data);
  } catch (err) {
    console.error("[CHAIN STATE] ❌ Failed to read:", err);
    return null;
  }
}

export async function writeChainState(newState: any): Promise<void> {
  try {
    const release = await lockfile.lock(statePath);
    fs.writeFileSync(statePath, JSON.stringify(newState, null, 2), "utf8");
    release();
    console.log("[CHAIN STATE] ✅ State written.");
  } catch (err) {
    console.error("[CHAIN STATE] ❌ Failed to write:", err);
  }
}
