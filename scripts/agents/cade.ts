import fs from 'fs';
import path from 'path';
import { db } from '../../db/client';
import { tasks } from '../../db/schema';
import { v4 as uuidv4 } from 'uuid';

const TASKS_DIR = path.resolve('./memory/tasks');
console.log('🟢 Cade starting... task folder:', TASKS_DIR);

async function logTask(
  type: string,
  payload: any,
  status: string,
  result: any
) {
  try {
    db.insert(tasks).values({
      id: uuidv4(),
      type,
      payload: JSON.stringify(payload),
      status,
      created_at: new Date().toISOString(),
      completed_at: new Date().toISOString(),
    }).run();
  } catch (err: any) {
    console.error('⚠️ Failed to log task:', err.message || err);
  }
}

export async function cadeCommandRouter(
  type: 'read file' | 'write to file' | 'delete file',
  payload: { path: string; content?: string }
) {
  const filePath = path.resolve(payload.path);

  // Basic safety: allow only paths inside project memory
  if (!filePath.startsWith(path.resolve('./memory'))) {
    const result = { message: 'Unsafe file path.' };
    await logTask(type, payload, 'error', result);
    return { status: 'error', result };
  }

  try {
    switch (type) {
      case 'read file': {
        if (!fs.existsSync(filePath)) {
          const result = { message: 'File does not exist.' };
          await logTask(type, payload, 'error', result);
          return { status: 'error', result };
        }
        const content = fs.readFileSync(filePath, 'utf-8');
        const result = { content };
        await logTask(type, payload, 'success', result);
        return { status: 'success', result };
      }

      case 'write to file': {
        fs.writeFileSync(filePath, payload.content || '', 'utf-8');
        const result = { message: `File written to ${payload.path}` };
        await logTask(type, payload, 'success', result);
        return { status: 'success', result };
      }

      case 'delete file': {
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
          const result = { message: `File deleted ${payload.path}` };
          await logTask(type, payload, 'success', result);
          return { status: 'success', result };
        } else {
          const result = { message: 'File does not exist.' };
          await logTask(type, payload, 'error', result);
          return { status: 'error', result };
        }
      }

      default: {
        const result = { message: 'Unknown task type.' };
        await logTask(type, payload, 'error', result);
        return { status: 'error', result };
      }
    }
  } catch (err: any) {
    const result = { message: err.message || String(err) };
    await logTask(type, payload, 'error', result);
    return { status: 'error', result };
  }
}
