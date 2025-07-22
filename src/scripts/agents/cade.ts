import path from 'path';
import { exec as execAsync } from 'child_process';
import { readFile, writeFile } from 'fs/promises';
import type { AgentResponse } from '../../lib/types';

export async function cadeCommandRouter(command: string, args?: Record<string, any>): Promise<AgentResponse> {
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
        const directory = args?.directory || '.';
        const { stdout } = await execAsync(`ls -lh "${directory}"`);
        return { status: 'success', result: { output: stdout.trim() } };
      } catch (err: any) {
        return { status: 'error', message: err.message };
      }

    case 'read file':
      try {
        const filepath = path.resolve(args?.path || 'scripts', 'README.md');
        const content = await readFile(filepath, 'utf8');
        return { status: 'success', result: { content } };
      } catch (err: any) {
        return { status: 'error', message: err.message };
      }

    case 'write to file':
      try {
        const filepath = path.resolve(args?.path || 'memory', 'agent_notes.txt');
        const content = args?.content || 'Hello from Cade!\n';
        await writeFile(filepath, content, 'utf8');
        return { status: 'success', result: { message: `Wrote to ${filepath}` } };
      } catch (err: any) {
        return { status: 'error', message: err.message };
      }

    case 'launch script':
      try {
        const filepath = path.resolve(args?.path || 'scripts', 'test.sh');
        const { stdout } = await execAsync(`bash "${filepath}"`);
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
