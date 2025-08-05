import { createAgentRuntime } from "../../mirror/agent.ts";
import { cade } from "../../agents/cade.ts";
import { startCadeTaskProcessor } from "./utils/cade_task_processor.js";

// Start Cade runtime
createAgentRuntime(cade);

// Start the task processor
startCadeTaskProcessor();

console.log("⚡ Cade runtime started with task processor enabled.");

// Keep the process alive
setInterval(() => {}, 1 << 30);
