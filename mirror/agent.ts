import { runAgent } from "../gizmo/engine.js";
import type { AgentConstructor } from "../gizmo";

export function createAgentRuntime(agent: AgentConstructor) {
  runAgent(agent, {
    local: true,
    env: "dev"
  });
}
