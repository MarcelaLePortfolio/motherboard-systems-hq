// <0001faf1> Phase 9.3a — Matilda Launcher Cleanup
import { createAgentRuntime } from "../../mirror/agent";
import { matilda } from "../../agents/matilda";

// ✅ Use unified runtime pattern (no task processor import)
createAgentRuntime(matilda);

console.log("💚 Matilda runtime started successfully via mirror/agent.ts.");
