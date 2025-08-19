export async function handleTask(task: { type: string; [key: string]: any }): Promise<any> {
  return {
    status: 'error',
    message: `Handler for task type "${task.type}" not implemented.`,
  };
}
