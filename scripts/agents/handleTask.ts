import { requeueTask } from '../utils/retryQueue';
import { saveLastTask } from '../utils/saveState';
import { taskSchema } from './taskSchema';
import { routeTask } from './routeTask';

export async function handleTask(task: any): Promise<{ status: string; result: string }> {
  saveLastTask(task); // 💾 Save task before processing
  const parsed = taskSchema.safeParse(task);
  if (!parsed.success) {
    requeueTask(task); // ♻️ Add to retry queue
    return {
      status: 'Failed',
      result: `❌ Validation error: ${parsed.error.message}`,
    };
  }

  const validTask = parsed.data;
  return await routeTask(validTask);
}
