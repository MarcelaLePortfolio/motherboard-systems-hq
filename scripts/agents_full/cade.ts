import { promises as fs } from 'fs';
import path from 'path';

export async function cadeCommandRouter(action: string, options: any) {
  try {
    switch(action) {
      case 'read file':
        return await fs.readFile(options.path, 'utf-8');

      case 'write file':
        await fs.mkdir(path.dirname(options.path), { recursive: true });
        await fs.writeFile(options.path, options.content, 'utf-8');
        return { status: 'success', path: options.path };

      case 'list files':
        const entries = await fs.readdir(options.dir, { withFileTypes: true });
        return entries.map(e => e.name);

      case 'delete':
        await fs.rm(options.path, { recursive: true, force: true });
        return { status: 'deleted', path: options.path };

      case "commit changes":
        const message = options?.message || "Auto-commit via Cade";
        const { exec } = require("child_process");
        return new Promise((resolve, reject) => {
          exec(`git add . && git commit -m \"${message}\"`, { cwd: process.cwd() }, (err, stdout, stderr) => {
            if (err) return reject(stderr || err.message);
            resolve({ status: "committed", message: stdout.trim() });
          });
        });
      case "newHandler":
        return { status: "stub replaced", handler: "newHandler" };
      default:
        return { error: 'Unknown action' };
    }
  } catch (err) {
    return { error: err.message };
  }
}
