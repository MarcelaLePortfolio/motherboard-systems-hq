import path from 'path';
import fs from 'fs';

import { generateFileWithOllama } from './handlers/generateFileWithOllama';
import { summarizeWithOllama } from './handlers/summarizeWithOllama';
import { explainCodeWithOllama } from './handlers/explainCodeWithOllama';
import { formatCommentsWithOllama } from './handlers/formatCommentsWithOllama';
import { runCommandWithCade } from './handlers/runCommandWithCade';
import { commentCodeWithOllama } from './handlers/commentCodeWithOllama';
import { translateCommentsWithOllama } from './handlers/translateCommentsWithOllama';
import { convertCodeWithOllama } from './handlers/convertCodeWithOllama';
import { refactorCodeWithOllama } from './handlers/refactorCodeWithOllama';
import { installDepsWithCade } from './handlers/installDepsWithCade';
import { startAgentWithPM2 } from './handlers/startAgentWithPM2';

import { ensureDir } from '../../_local/utils/fsHelpers';

export async function cadeCommandRouter(command: string, args?: any) {
  try {
    switch (command) {
      case 'translate': {
        return await translateCommentsWithOllama(args);
      }

      case 'convert': {
        return await convertCodeWithOllama(args);
      }

      case 'comment': {
        return await commentCodeWithOllama(args);
      }

      case 'refactor': {
        return await refactorCodeWithOllama(args);
      }

      case 'install dependencies': {
        return await installDepsWithCade(args);
      }

      case 'start agent': {
        return { status: 'error', message: `Unknown command: ${command}` };
    switch (command) {
      case 'translate': {
        return await translateCommentsWithOllama(args);
      }
      case 'convert': {
        return await convertCodeWithOllama(args);
      }
      case 'comment': {
        return await commentCodeWithOllama(args);
      }
      case 'refactor': {
        return await refactorCodeWithCade(args);
      }
      case 'install dependencies': {
        return await installDepsWithCade(args);
      }
      case 'start agent': {
        return await startAgentWithPM2(args);
      }
      case 'generate': {
        return await generateFileWithOllama(args);
      }
      case 'summarize': {
        return await summarizeWithOllama(args);
      }
      case 'explain': {
        return await explainCodeWithOllama(args);
      }
      case 'format': {
        return await formatCommentsWithOllama(args);
      }
      case 'run command': {
        return await runCommandWithCade(args);
      }
      default:
        return { status: "error", message: `Unknown command: ${command}` };
    }
    }    }
  } catch (err: any) {
    return { status: 'error', message: err.message || String(err) };
  }
}

function validateSafePath(inputPath: string, opts: { allowNonexistent?: boolean; mustBeWithinCwd?: boolean } = {}) {
  if (!inputPath || typeof inputPath !== 'string') throw new Error('No file path provided.');
  const resolved = path.resolve(inputPath);
  const cwd = process.cwd();

  if (opts.mustBeWithinCwd !== false) {
    if (!resolved.startsWith(cwd + path.sep) && resolved !== cwd) {
      throw new Error('Unsafe file path.');
    }
  }

  if (!opts.allowNonexistent && !fs.existsSync(resolved)) {
    throw new Error('File does not exist.');
  }

  return resolved;
}
