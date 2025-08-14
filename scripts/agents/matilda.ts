import { cadeCommandRouter } from './cade';

export async function matildaCommandRouter(input: string) {
  const lower = input.toLowerCase();

  if (lower.includes('start full task')) {
    return await cadeCommandRouter('start full task delegation cycle');
  }

  if (lower.includes('read chain state')) {
    return await cadeCommandRouter('read chain state');
  }

  return {
    status: 'ok',
    message: `🤖 Matilda received your message but didn’t recognize the task.`,
  };
}
