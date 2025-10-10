 
type AgentResponse = {
  status: 'success' | 'error';
  message?: string;
  result?: any;
};

export async function dispatchCommand(agent: string, command: string): Promise<AgentResponse> {
  switch (agent.toLowerCase()) {
    case 'cade':
////      const { cadeCommandRouter } = await import('../scripts/agents/cade');
      return cadeCommandRouter(command);
    default:
      return { status: 'error', message: `Unknown agent: ${agent}` };
  }
}
