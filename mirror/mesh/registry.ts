const AgentRegistry = new Map<string, any>();

export function registerAgent(name: string, agent: any) {
  AgentRegistry.set(name, agent);
  console.log(`[MESH] registered agent: ${name}`);
}

export function getAgent(name: string) {
  return AgentRegistry.get(name);
}

export function listAgents() {
  return Array.from(AgentRegistry.keys());
}

export { AgentRegistry };
