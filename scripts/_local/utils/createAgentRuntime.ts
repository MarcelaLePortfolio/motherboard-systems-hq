import { Agent } from "../../types";

export function createAgentRuntime(agent: Agent) {
  console.log(`�� Launching ${agent.name} agent...`);
  agent.start();
}
