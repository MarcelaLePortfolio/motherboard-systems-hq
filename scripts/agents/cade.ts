import { handleLearn } from './handlers/learn';
import { handleTask } from './cade_task_processor';

// Expose both handleTask and commandRouter
export { handleTask };

// Central command dispatcher (used in manual tests or delegation)
export async function cadeCommandRouter(command: string, args?: any): Promise<any> {
  if (command === 'learn') {
    return await handleLearn(args || { targetPath: 'docs', namespace: 'default' });
  }

  return await handleTask({ type: command, ...args });
}
