import { v4 as uuidv4 } from 'uuid';
import { cadeCommandRouter } from './cade';
import { logTask } from '../../db/logTask';

// Matilda agent: Delegates tasks into Cade’s enterprise pipeline
export async function matildaCommandRouter(command: string, payload: any = {}, actor: string = 'matilda') {
  const taskId = uuidv4();

  // Log delegation intent
  await logTask({
    id: taskId,
    type: command,
    status: 'delegated',
    actor,
    payload,
    result: JSON.stringify({ message: `Delegating to Cade` }),
    created_at: new Date().toISOString(),
  });

  // Forward to Cade
  const result = await cadeCommandRouter(command, payload, actor);

  // Log final outcome under same taskId for traceability
  await logTask({
    id: taskId,
    type: command,
    status: result?.status || 'unknown',
    actor,
    payload,
    result: JSON.stringify(result),
    created_at: new Date().toISOString(),
  });

  return { status: 'success', delegated_to: 'cade', result };
}
