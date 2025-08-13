 
import { cadeCommandRouter } from '../agents/cade';

export async function delegateToCade(payload  {
  command: string;
  args?: Record<string, any>;
  sourceAgent?: string;
}) {
  const { command, args, sourceAgent } = payload;

  // Log source
  const origin = sourceAgent ? `🔁 Routed from ${sourceAgent}` : '<0001f9e0> Internal delegation';

  // Optionally log to file (can be adjusted to a DB/store later)
  const timestamp = new Date().toISOString();
  const routedLog = `[${timestamp}] ${origin}: ${command} ${args ? JSON.stringify(args) : ''}
`;
  await Bun.write('memory/cade_routed_commands.log', routedLog, { append: true });

  // Route and return result
  const result = await cadeCommandRouter(command, args);
  return {
    routedBy: 'delegateToCade',
    sourceAgent: sourceAgent || 'unknown',
    result
  };
}
