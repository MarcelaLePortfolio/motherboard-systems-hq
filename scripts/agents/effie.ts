import { v4 as uuidv4 } from 'uuid';
import { cadeCommandRouter } from './cade';
import { logTask } from '../../db/logTask';

// Effie agent: delegates tasks into Cade’s enterprise pipeline
export async function effieCommandRouter(
  command: string,
  payload: Record<string, any> = {},
  actor: string = 'effie'
) {
  const taskId = uuidv4();
  const createdAt = new Date().toISOString();

  // Delegation intent
  await logTask(
    command,
    payload,
    'delegated',
    { message: 'Delegating to Cade' },
    { actor, taskId, fileHash: null }
  );

  // Forward to Cade
  const result = await cadeCommandRouter(command, payload, actor);

  // Final outcome
  await logTask(
    command,
    payload,
    (result?.status as 'success' | 'error' | 'unknown') ?? 'unknown',
    result,
    {
      actor,
      taskId,
      fileHash:
        result?.result?.hash ||
        result?.result?.prev_hash ||
        null,
    }
  );

  return { status: 'success', delegated_to: 'cade', result };
}
