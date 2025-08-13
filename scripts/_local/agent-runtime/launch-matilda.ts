 
import { createAgentRuntime } from "../../mirror/agent.ts";
import { startMatildaTaskProcessor } from "./utils/matilda_task_processor.ts";
import { matilda } from "../../agents/matilda.ts";

// Start Matilda runtime
createAgentRuntime(matilda);
console.log("💚 Matilda runtime started.");

// Keep the process alive
setInterval(() => {}, 1 << 30);

startMatildaTaskProcessor();
