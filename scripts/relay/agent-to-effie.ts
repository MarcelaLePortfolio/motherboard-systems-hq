 
import { effieCommandRouter } from '../agents/effie';

export async function delegateToEffie(payload  {
  command: string;
  args?: Record<string, any>;
  sourceAgent?: string;
}) {
  const { command, args, sourceAgent } = payload;

  const origin = sourceAgent ? `🔁 Routed from ${sourceAgent}` : '<0001f9e0> Internal delegation';
  const timestamp = new Date().toISOString();
  const routedLog = `[${timestamp}] ${origin}: ${command} ${args ? JSON.stringify(args) : ''}
`;

  await Bun.write('memory/effie_routed_commands.log', routedLog, { append: true });

  const result = await effieCommandRouter(command, args);
  return {
    routedBy: 'delegateToEffie',
    sourceAgent: sourceAgent || 'unknown',
    result
  };
}
