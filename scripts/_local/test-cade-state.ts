import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const statePath = path.join(__dirname, "../../../memory/agent_chain_state.json");

function log(msg: string) {
  console.log(`[CADE-STATE-TEST] ${msg}`);
}

function readState(): any {
  try {
    const data = fs.readFileSync(statePath, "utf8");
    log("✅ State read:");
    console.log(data);
    return JSON.parse(data);
  } catch (err) {
    log("❌ Failed to read state:");
    console.error(err);
    return null;
  }
}

function writeState(newState: any) {
  try {
    fs.writeFileSync(statePath, JSON.stringify(newState, null, 2), "utf8");
    log("✅ State written successfully.");
  } catch (err) {
    log("❌ Failed to write state:");
    console.error(err);
  }
}

function testReadWriteCycle() {
  log("�� Starting read/write test cycle...");

  const current = readState();
  if (!current) return;

  const updated = {
    ...current,
    status: "Working",
    ts: Date.now()
  };

  writeState(updated);

  const verify = readState();
  log("🔍 Final verification:");
  console.log(verify);
}

testReadWriteCycle();
