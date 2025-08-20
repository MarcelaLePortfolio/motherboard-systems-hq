import { logTask } from '../utils/taskLogger';
import { setupGracefulShutdown, trackTask } from '../utils/setupGracefulShutdown';
import { requeueTask } from '../utils/retryQueue';
import { saveLastTask } from '../utils/saveState';
import { taskSchema } from './taskSchema';
import { routeTask } from './routeTask';

setupGracefulShutdown();
export async function handleTask(task: any): Promise<{ status: string; result: string }> {
  saveLastTask(task); // 💾 Save task before processing
  trackTask(task); // 👣 Track task for graceful shutdown
  const parsed = taskSchema.safeParse(task);
  if (!parsed.success) {
    requeueTask(task); // ♻️ Add to retry queue
    return {
      status: 'Failed',
      result: `❌ Validation error: ${parsed.error.message}`,
    };
  }

  const validTask = parsed.data;
  const result = await routeTask(validTask);
  logTask(validTask, result);
  return await routeTask(validTask);
}
