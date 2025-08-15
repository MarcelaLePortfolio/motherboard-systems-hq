import fs from 'fs';
import path from 'path';
import { runOllamaInference } from '../_local/utils/ollamaClient';

export async function cadeCommandRouter(command: string, args: any = {}) {
  try {
    switch (command) {
      case 'echo':
        return { status: 'success', message: args.message || '' };

      case 'list files': {
        const targetDir = args.dir || '.';
        const resolvedDir = path.resolve(targetDir);
        const files = fs.readdirSync(resolvedDir);
        return { status: 'success', files };
      }

      case 'read file': {
        const safePath = validateSafePath(args.path);
        const content = fs.readFileSync(safePath, 'utf-8');
        return { status: 'success', content };
      }

      case 'write to file': {
        const safePath = validateSafePath(args.path);
        fs.writeFileSync(safePath, args.content || '', 'utf-8');
        return { status: 'success', path: safePath };
      }

      case 'summarize': {
        const safePath = validateSafePath(args.file);
        const content = fs.readFileSync(safePath, 'utf-8');
        const prompt = `Summarize the following file content clearly and concisely:\n\n${content}`;
        const summary = await runOllamaInference(prompt);
        return { status: 'success', summary };
      }

      default:
        return { status: 'error', message: `Unknown command: ${command}` };
    }
  } catch (err: any) {
    return { status: 'error', message: err.message };
  }
}

function validateSafePath(inputPath: string) {
  if (!inputPath) throw new Error('No file path provided.');
  const resolvedPath = path.resolve(inputPath);
  if (!resolvedPath.startsWith(process.cwd())) {
    throw new Error('Unsafe file path.');
  }
  if (!fs.existsSync(resolvedPath)) {
    throw new Error('File does not exist.');
  }
  return resolvedPath;
}
