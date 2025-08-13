 
import { log } from '../utils/log';
import { promises as fs } from 'fs';
////import path from 'path';

export async function effieCommandRouter(command: string, args?: Record<string, any>) {
  try {
    switch (command) {
      case 'read file':
        if (!args?.path) throw new Error('Missing path');
        return { status: 'success', result: await fs.readFile(args.path, 'utf-8') };

      case 'write file':
        if (!args?.path || typeof args?.content !== 'string') throw new Error('Missing path or content');
        await fs.writeFile(args.path, args.content);
        return { status: 'success', result: `Wrote to ${args.path}` };

      case 'delete file':
        if (!args?.path) throw new Error('Missing path');
        await fs.unlink(args.path);
        return { status: 'success', result: `Deleted ${args.path}` };

      case 'move file':
        if (!args?.from || !args?.to) throw new Error('Missing from/to');
        await fs.rename(args.from, args.to);
        return { status: 'success', result: `Moved ${args.from} to ${args.to}` };

      case 'list files':
        if (!args?.dir) throw new Error('Missing dir');
////////        const files = await fs.readdir(args.dir);
        return { status: 'success', result: files };

      default:
        return { status: 'error', message: `Unknown command: ${command}` };
    }
  } catch (err: any) {
    await log(`Effie error: ${err.message}`);
    return { status: 'error', message: err.message };
  }
}

/**
 * Named export for Effie agent
 */
export const effie = {
  name: "Effie",
  role: "Desktop/Local Ops Assistant",
  handler: effieCommandRouter
};
