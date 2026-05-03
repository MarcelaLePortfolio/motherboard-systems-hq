 
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import lockfile from "proper-lockfile";

const statePath = path.resolve(process.cwd(), "memory", "agent_chain_state.json");

function log(msg: string) {
  console.log(`[CADE-STATE-TEST] ${msg}`);
}

async function readState(): Promise<any> {
  try {
    const release = await lockfile.lock(statePath);
    const data = fs.readFileSync(statePath, "utf8");
    release();
    log("✅ State read:");
    console.log(data);
    return JSON.parse(data);
  } catch (err) {
    log("❌ Failed to read state:");
    console.error(err);
    return null;
  }
}

async function writeState(newState: any) {
  try {
    const release = await lockfile.lock(statePath);
    fs.writeFileSync(statePath, JSON.stringify(newState, null, 2), "utf8");
    release();
    log("✅ State written successfully.");
  } catch (err) {
    log("❌ Failed to write state:");
    console.error(err);
  }
}

async function testReadWriteCycle() {
  log("🔁 Starting read/write test cycle...");

  const current = await readState();
  if (!current) return;

  const updated = {
    ...current,
    status: "Working",
    ts: Date.now()
  };

  await writeState(updated);

  const verify = await readState();
  log("🔍 Final verification:");
  console.log(verify);
}

testReadWriteCycle();
