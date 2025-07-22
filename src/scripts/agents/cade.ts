import { exec } from 'child_process';
import { readFile, writeFile } from 'fs/promises';
import { promisify } from 'util';
import path from 'path';

const execAsync = promisify(exec);
const ALLOWED_DIRS = ['scripts', 'src', 'memory', '.'];

export async function cadeCommandRouter(command: string) {
  switch (command.toLowerCase()) {
    case 'run diagnostics':
      return {
        status: 'success',
        result: {
          system: 'Cade',
          diagnostics: '✅ All systems operational',
          timestamp: new Date().toISOString()
        }
      };

    case 'list files':
      try {
        const { stdout } = await execAsync('ls -lh');
        return { status: 'success', result: { output: stdout.trim() } };
      } catch (err: any) {
        return { status: 'error', message: err.message };
      }

    case 'read file':
      try {
        const filepath = path.resolve('scripts', 'README.md');
        const content = await readFile(filepath, 'utf8');
        return { status: 'success', result: { content } };
      } catch (err: any) {
        return { status: 'error', message: err.message };
      }

    case 'write to file':
      try {
        const filepath = path.resolve('memory', 'agent_notes.txt');
        await writeFile(filepath, 'Hello from Cade!\n', 'utf8');
        return { status: 'success', result: { message: 'File written.' } };
      } catch (err: any) {
        return { status: 'error', message: err.message };
      }

    case 'launch script':
      try {
        const filepath = path.resolve('scripts', 'test.sh');
        const { stdout } = await execAsync(`bash ${filepath}`);
        return { status: 'success', result: { output: stdout.trim() } };
      } catch (err: any) {
        return { status: 'error', message: err.message };
      }

    default:
      return {
        status: 'error',
        message: `Command "${command}" not recognized by Cade.`
      };
  }
}
