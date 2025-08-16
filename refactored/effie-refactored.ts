```ts
import { log } from '../utils/log.js';
import { promises as fs } from 'fs';

interface CommandOptions {
  path?: string;
  content?: string;
  from?: string;
  to?: string;
  dir?: string;
}

export async function effieCommandRouter(command: string, args?: Record<string, any>) {
  const commandHandlers = [
    { name: 'read file', handler: readFileSyncHandler },
    { name: 'write file', handler: writeFileSyncHandler },
    { name: 'delete file', handler: deleteFileHandler },
    { name: 'move file', handler: moveFileHandler },
    { name: 'list files', handler: listFilesHandler }
  ];

  try {
    const commandHandler = commandHandlers.find((handler) => handler.name === command);
    if (!commandHandler) return { status: 'error', message: `Unknown command: ${command}` };

    const options = args as CommandOptions;
    switch (command) {
      case 'read file':
        return await readFileSyncHandler(options);

      case 'write file':
        return await writeFileSyncHandler(options);

      case 'delete file':
        return await deleteFileHandler(options);

      case 'move file':
        return await moveFileHandler(options);

      case 'list files':
        return await listFilesHandler(options);
    }
  } catch (err: any) {
    await log(`Effie error: ${err.message}`);
    return { status: 'error', message: err.message };
  }
}

async function readFileSyncHandler({ path }: CommandOptions): Promise<{ status: string; result?: any }> {
  if (!path) throw new Error('Missing path');
  try {
    const content = await fs.readFile(path, 'utf-8');
    return { status: 'success', result: content };
  } catch (err: any) {
    throw err;
  }
}

async function writeFileSyncHandler({ path, content }: CommandOptions): Promise<{ status: string; result?: any }> {
  if (!path || typeof content !== 'string') throw new Error('Missing path or content');
  try {
    await fs.writeFile(path, content);
    return { status: 'success', result: `Wrote to ${path}` };
  } catch (err: any) {
    throw err;
  }
}

async function deleteFileHandler({ path }: CommandOptions): Promise<{ status: string; result?: any }> {
  if (!path) throw new Error('Missing path');
  try {
    await fs.unlink(path);
    return { status: 'success', result: `Deleted ${path}` };
  } catch (err: any) {
    throw err;
  }
}

async function moveFileHandler({ from, to }: CommandOptions): Promise<{ status: string; result?: any }> {
  if (!from || !to) throw new Error('Missing from/to');
  try {
    await fs.rename(from, to);
    return { status: 'success', result: `Moved ${from} to ${to}` };
  } catch (err: any) {
    throw err;
  }
}

async function listFilesHandler({ dir }: CommandOptions): Promise<{ status: string; result?: any }> {
  if (!dir) throw new Error('Missing dir');
  try {
    const files = await fs.readdir(dir);
    return { status: 'success', result: files };
  } catch (err: any) {
    throw err;
  }
}

export const effie = {
  name: "Effie",
  role: "Desktop/Local Ops Assistant",
  handler: effieCommandRouter
};
```