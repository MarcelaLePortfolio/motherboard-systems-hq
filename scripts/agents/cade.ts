// scripts/agents/cade.ts
import fs from 'fs';
import path from 'path';

const TASKS_DIR = path.resolve('./memory/tasks');
console.log('🟢 Cade starting... task folder:', TASKS_DIR);

export async function cadeCommandRouter(
  type: 'read file' | 'write to file' | 'delete file',
  payload: { path: string; content?: string }
) {
  const filePath = path.resolve(payload.path);

  // Basic safety: allow only paths inside project memory
  if (!filePath.startsWith(path.resolve('./memory'))) {
    return { status: 'error', message: 'Unsafe file path.' };
  }

  try {
    switch (type) {
      case 'read file':
        if (!fs.existsSync(filePath)) {
          return { status: 'error', message: 'File does not exist.' };
        }
        const content = fs.readFileSync(filePath, 'utf-8');
        return { status: 'success', content };

      case 'write to file':
        fs.writeFileSync(filePath, payload.content || '', 'utf-8');
        return { status: 'success', message: `File written to ${payload.path}` };

      case 'delete file':
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
          return { status: 'success', message: `File deleted ${payload.path}` };
        } else {
          return { status: 'error', message: 'File does not exist.' };
        }

      default:
        return { status: 'error', message: 'Unknown task type.' };
    }
  } catch (err: any) {
    return { status: 'error', message: err.message || String(err) };
  }
}