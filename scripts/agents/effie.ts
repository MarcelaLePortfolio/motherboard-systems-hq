import { v4 as uuidv4 } from 'uuid';
import { cadeCommandRouter } from './cade';
import { logTask } from '../../db/logTask';

// Effie agent: Handles local or desktop operations
export async function effieCommandRouter(command: string, payload: any = {}, actor: string = 'effie') {
  const taskId = uuidv4();
  const createdAt = new Date().toISOString();

  // Delegation intent
  await logTask({
    id: taskId,
    task_id: null,
    type: command,
    status: 'delegated',
    actor,
    payload: JSON.stringify(payload),
    result: JSON.stringify({ message: `Delegating to Cade` }),
    file_hash: null,
    created_at: createdAt,
  });

  // Forward to Cade
  const result = await cadeCommandRouter(command, payload, actor);

  // Final outcome
  await logTask({
    id: taskId,
    task_id: null,
    type: command,
    status: result?.status || 'unknown',
    actor,
    payload: JSON.stringify(payload),
    result: JSON.stringify(result),
    file_hash: result?.result?.hash || result?.result?.prev_hash || null,
    created_at: new Date().toISOString(),
  });

  return { status: 'success', delegated_to: 'cade', result };
}
