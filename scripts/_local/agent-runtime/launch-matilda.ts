// <0001faf6> Phase 9.5 — Matilda Agent Path Restored + Live Relaunch Verified
import { createAgentRuntime } from "../../mirror/agent.mjs";
import { matilda } from "../../agents/matilda/matilda.mjs";

createAgentRuntime(matilda);
console.log("💚 Matilda runtime successfully relaunched via mirror/agent.mjs");
