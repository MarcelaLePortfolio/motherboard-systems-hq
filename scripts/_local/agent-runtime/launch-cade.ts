<<<<<<< HEAD
import { startCadeTaskProcessor } from "./utils/cade_task_processor.ts";

console.log("⚡ Cade runtime started with task processor enabled.");
startCadeTaskProcessor();
=======
import { processOnce } from "../../../src/agents/cade/processor";

async function main() {
  setInterval(() => { processOnce().catch(() => {}); }, 2000);
   
  console.log("Cade runtime polling memory/agent_chain_state.json every 2s.");
}
main();
>>>>>>> cade-hardening
