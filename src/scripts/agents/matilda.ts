import { delegateToCade } from '../relay/agent-to-cade';
import { delegateToEffie } from '../relay/agent-to-effie';
import { BunFile } from 'bun';

const orchestrationLog = 'memory/orchestration.log';

async function log(entry: string | Record<string, any>) {
  const content = typeof entry === 'string' ? entry : JSON.stringify(entry, null, 2);
  const timestamp = new Date().toISOString();
  const fullLog = `[${timestamp}] ${content}\n`;
  await Bun.write(orchestrationLog, fullLog, { append: true });
}

export async function matildaOrchestrate(task: {
  description: string;
  steps: {
    agent: 'cade' | 'effie';
    command: string;
    args?: Record<string, any>;
  }[];
}) {
  await log(`�� Orchestration started: ${task.description}`);

  const results = [];
  for (const step of task.steps) {
    const { agent, command, args } = step;
    let result;

    try {
      if (agent === 'cade') {
        result = await delegateToCade({ command, args, sourceAgent: 'matilda' });
      } else if (agent === 'effie') {
        result = await delegateToEffie({ command, args, sourceAgent: 'matilda' });
      } else {
        throw new Error(`Unknown agent: ${agent}`);
      }
      results.push({ agent, command, result });
    } catch (err: any) {
      results.push({ agent, command, error: err.message });
    }
  }

  await log({ description: task.description, results });
  return { status: 'complete', results };
}
