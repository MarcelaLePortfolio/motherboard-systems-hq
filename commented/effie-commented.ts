Here is the updated code with helpful inline comments:
```
import { log } from '../utils/log.js';
import { promises as fs } from 'fs';

export async function effieCommandRouter(command: string, args?: Record<string, any>) {
  try {
    // Use a switch statement to handle different commands
    switch (command) {
      case 'read file':
        // Check if the `args.path` property is present
        if (!args?.path) throw new Error('Missing path');
        // Read the file using fs.readFile and return the result
        return { status: 'success', result: await fs.readFile(args.path, 'utf-8') };

      case 'write file':
        // Check if both `args.path` and `args.content` are present
        if (!args?.path || typeof args?.content !== 'string') throw new Error('Missing path or content');
        // Write the file using fs.writeFile
        await fs.writeFile(args.path, args.content);
        return { status: 'success', result: `Wrote to ${args.path}` };

      case 'delete file':
        // Check if the `args.path` property is present
        if (!args?.path) throw new Error('Missing path');
        // Delete the file using fs.unlink
        await fs.unlink(args.path);
        return { status: 'success', result: `Deleted ${args.path}` };

      case 'move file':
        // Check if both `args.from` and `args.to` are present
        if (!args?.from || !args?.to) throw new Error('Missing from/to');
        // Move the file using fs.rename
        await fs.rename(args.from, args.to);
        return { status: 'success', result: `Moved ${args.from} to ${args.to}` };

      case 'list files':
        // Check if the `args.dir` property is present
        if (!args?.dir) throw new Error('Missing dir');
        const files = await fs.readdir(args.dir);
        return { status: 'success', result: files };

      default:
        // Return an error message for unknown commands
        return { status: 'error', message: `Unknown command: ${command}` };
    }
  } catch (err: any) {
    // Log the error and return it
    await log(`Effie error: ${err.message}`);
    return { status: 'error', message: err.message };
  }
}

export const effie = {
  name: "Effie",
  role: "Desktop/Local Ops Assistant",
  handler: effieCommandRouter
};
```