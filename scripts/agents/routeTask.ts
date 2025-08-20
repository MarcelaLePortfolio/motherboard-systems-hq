import fs from 'fs';
import path from 'path';

export async function routeTask(task: any): Promise<{ status: string; result: string }> {
  const { type, payload } = task;

  switch (type) {
    case 'echo':
      return { status: 'success', result: `Echo: ${JSON.stringify(payload)}` };

    case 'read': {
      const safePath = path.resolve('memory', path.basename(payload.path));
      if (!safePath.startsWith(path.resolve('memory'))) {
        return { status: 'error', result: 'Unsafe file path.' };
      }
      try {
        const content = fs.readFileSync(safePath, 'utf-8');
        return { status: 'success', result: content };
      } catch (err: any) {
        return { status: 'error', result: `Failed to read file: ${err.message}` };
      }
    }

    case 'write': {
      await new Promise(r => setTimeout(r, 10000)); // ⏱️ Simulate crash timing
      const safePath = path.resolve('memory', path.basename(payload.path));
      if (!safePath.startsWith(path.resolve('memory'))) {
        return { status: 'error', result: 'Unsafe file path.' };
      }
      try {
        fs.mkdirSync('memory', { recursive: true });
        fs.writeFileSync(safePath, payload.content || '');
        return { status: 'success', result: `Wrote to ${payload.path}` };
      } catch (err: any) {
        return { status: 'error', result: `Failed to write file: ${err.message}` };
      }
    }

    default:
      return { status: 'skipped', result: 'Unknown task type' };
  }
}
