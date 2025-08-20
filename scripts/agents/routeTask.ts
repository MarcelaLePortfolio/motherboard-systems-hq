import { handleEcho } from './handlers/handleEcho';
import { handlePatch } from './handlers/handlePatch';
import { handleDelete } from './handlers/handleDelete';

export async function routeTask(task) {
  switch (task.type) {
    case 'echo':
      return await handleEcho(task);
    case 'patch':
      return await handlePatch(task);
    case 'delete':
      return await handleDelete(task);
    default:
      console.warn("⚠️ Unknown task type:", task.type);
      return { status: 'skipped', result: 'Unknown task type' };
  }
}
