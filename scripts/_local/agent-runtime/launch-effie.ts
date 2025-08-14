import "dotenv/config"
 
import { createAgentRuntime } from "../../mirror/agent.mjs";
import { effie } from "../../agents/effie";

// Start Effie runtime
createAgentRuntime(effie);
console.log("💚 Effie runtime started.");

// Keep the process alive
setInterval(() => {}, 1 << 30);

// startEffieTaskProcessor(); // TODO: Implement effie task processor
