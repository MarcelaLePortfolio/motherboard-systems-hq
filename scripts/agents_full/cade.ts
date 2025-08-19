let replaceStubHandler; import("./handlers/replaceStubHandler.js").then(m => replaceStubHandler = m.default || m);
let startAgentHandler; import("./handlers/startAgentHandler.js").then(m => startAgentHandler = m.default || m);
let runScriptHandler; import("./handlers/runScriptHandler.js").then(m => runScriptHandler = m.default || m);
let installDepsHandler; import("./handlers/installDepsHandler.js").then(m => installDepsHandler = m.default || m);
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

      case "install deps": {
        if (!installDepsHandler) throw new Error("installDepsHandler not loaded");
        return installDepsHandler(options);
      }
      case "run script": {
        if (!runScriptHandler) throw new Error("runScriptHandler not loaded");
        return runScriptHandler(options);
      }
      case "start agent": {
        if (!startAgentHandler) throw new Error("startAgentHandler not loaded");
        return startAgentHandler(options);
      }
      case "replace stub": {
        if (!replaceStubHandler) throw new Error("replaceStubHandler not loaded");
        return replaceStubHandler(options);
      }
      default:
        return { error: 'Unknown action' };
    }
  } catch (err) {
    return { error: err.message };
  }
}
