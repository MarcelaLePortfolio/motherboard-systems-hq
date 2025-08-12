import { createAgentRuntime } from "../../mirror/agent";
import { cade } from "../../agents/cade";
import { readChainState } from "../utils/chainState";

async function testReadSharedState() {
  const state = await readChainState();
  console.log("🧠 [CADE] Shared state read at launch:");
  console.dir(state, { depth: null });
}

testReadSharedState(); // Minimal runtime test — to be removed or upgraded in Milestone 4

createAgentRuntime(cade);
