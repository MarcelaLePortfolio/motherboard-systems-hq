```ts
import { log } from '../utils/log.js';
import { promises as fs } from 'fs';

interface CommandType {
  command: string;
  args?: Record<string, any>;
}

export async function executeCommand(command: CommandType) {
  try {
    switch (command.command) {
      case 'read file':
        return await readFileSync(command.args?.path);

      case 'write file':
        return await writeFile(command.args?.path, command.args?.content);

      case 'delete file':
        return await deleteFile(command.args?.path);

      case 'move file':
        return await moveFile(command.args?.from, command.args?.to);

      case 'list files':
        return await listFiles(command.args?.dir);

      default:
        throw new Error(`Unknown command: ${command.command}`);
    }
  } catch (err: any) {
    await log(`Effie error: ${err.message}`);
    throw err;
  }
}

export async function readFileSync(path: string): Promise<{ status: 'success', result: string }> {
  if (!path) throw new Error('Missing path');
  return { status: 'success', result: await fs.readFile(path, 'utf-8') };
}

export async function writeFile(path: string, content: string): Promise<string> {
  if (!path || typeof content !== 'string') throw new Error('Missing path or content');
  await fs.writeFile(path, content);
  return `Wrote to ${path}`;
}

export async function deleteFile(path: string): Promise<string> {
  if (!path) throw new Error('Missing path');
  await fs.unlink(path);
  return `Deleted ${path}`;
}

export async function moveFile(from: string, to: string): Promise<string> {
  if (!from || !to) throw new Error('Missing from/to');
  await fs.rename(from, to);
  return `Moved ${from} to ${to}`;
}

export async function listFiles(dir: string): Promise<{ status: 'success', result: string[] }> {
  if (!dir) throw new Error('Missing dir');
  const files = await fs.readdir(dir);
  return { status: 'success', result: files };
}

/**
 * Named export for Effie agent
 */
export const effie = {
  name: "Effie",
  role: "Desktop/Local Ops Assistant",
  handler: executeCommand
};
```