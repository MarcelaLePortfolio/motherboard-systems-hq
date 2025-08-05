import { createAgentRuntime } from "../../mirror/agent.ts";
import { effie } from "../../agents/effie.ts";

// Start Effie runtime
createAgentRuntime(effie);
console.log("💚 Effie runtime started.");

// Keep the process alive
setInterval(() => {}, 1 << 30);
