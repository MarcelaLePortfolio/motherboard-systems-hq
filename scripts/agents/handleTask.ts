import { taskSchema } from './taskSchema';
import { routeTask } from './routeTask';

export async function handleTask(task: any): Promise<{ status: string; result: string }> {
  const parsed = taskSchema.safeParse(task);
  if (!parsed.success) {
    return {
      status: 'Failed',
      result: `❌ Validation error: ${parsed.error.message}`,
    };
  }

  const validTask = parsed.data;
  return await routeTask(validTask);
}
