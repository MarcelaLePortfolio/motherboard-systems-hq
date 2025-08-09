import { processOnce } from "../../../src/agents/cade/processor";

async function main() {
  setInterval(() => { processOnce().catch(() => {}); }, 2000);
   
  console.log("Cade runtime polling memory/agent_chain_state.json every 2s.");
}
main();
