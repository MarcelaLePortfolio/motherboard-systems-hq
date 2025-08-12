import { createAgentRuntime } from "../../mirror/agent";
import { startEffieTaskProcessor } from "./utils/effie_task_processor";
import { effie } from "../../agents/effie";

// Start Effie runtime
createAgentRuntime(effie);
console.log("💚 Effie runtime started.");

// Keep the process alive
setInterval(() => {}, 1 << 30);

startEffieTaskProcessor();
