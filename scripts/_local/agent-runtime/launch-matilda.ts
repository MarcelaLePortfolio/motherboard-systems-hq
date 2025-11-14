// <0001faf5> Phase 9.4a — Matilda Resurrection Cleanup
import { createAgentRuntime } from "../../mirror/agent";
import { matilda } from "../../agents/matilda/matilda.mjs";

createAgentRuntime(matilda);
console.log("💚 Matilda runtime restored and running cleanly via mirror/agent.ts");
