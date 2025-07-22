import { exec as execCallback } from 'child_process';
import { promises as fs } from 'fs';
import path from 'path';
import os from 'os';
import util from 'util';

const execAsync = util.promisify(execCallback);
const { readFile, writeFile, rename, unlink, appendFile } = fs;
const logPath = path.resolve('memory', 'cade-execution.log');

async function logCommand(command: string, args: any, status: string, result: any) {
  const entry = {
    timestamp: new Date().toISOString(),
    command,
    args,
    status,
    result
  };
  await appendFile(logPath, JSON.stringify(entry) + '\n', 'utf8');
}

export async function cadeCommandRouter(command: string, args?: any) {
  try {
    switch (command.toLowerCase()) {
      case 'read file': {
        const filepath = path.resolve(args?.path || 'scripts', 'README.md');
        const content = await readFile(filepath, 'utf8');
        const result = { content };
        await logCommand(command, args, 'success', result);
        return { status: 'success', result };
      }

      case 'write to file': {
        const filepath = path.resolve(args?.path || 'memory', 'agent_notes.txt');
        const content = args?.content || 'Hello from Cade!\n';
        await writeFile(filepath, content, 'utf8');
        const result = { message: `Wrote to ${filepath}` };
        await logCommand(command, args, 'success', result);
        return { status: 'success', result };
      }

      case 'launch script': {
        const filepath = path.resolve(args?.path || 'scripts', 'test.sh');
        const { stdout } = await execAsync(`bash "${filepath}"`);
        const result = { output: stdout.trim() };
        await logCommand(command, args, 'success', result);
        return { status: 'success', result };
      }

      case 'move file': {
        const fromPath = path.resolve(args?.from);
        const toPath = path.resolve(args?.to);
        await rename(fromPath, toPath);
        const result = { message: `Moved to ${toPath}` };
        await logCommand(command, args, 'success', result);
        return { status: 'success', result };
      }

      case 'delete file': {
        const targetPath = path.resolve(args?.path);
        await unlink(targetPath);
        const result = { message: `Deleted ${targetPath}` };
        await logCommand(command, args, 'success', result);
        return { status: 'success', result };
      }

      case 'open url': {
        const url = args?.url;
        if (!url) throw new Error('Missing URL argument.');
        const opener = os.platform() === 'darwin' ? 'open' : os.platform() === 'win32' ? 'start ""' : 'xdg-open';
        await execAsync(`${opener} "${url}"`);
        const result = { message: `Opened ${url}` };
        await logCommand(command, args, 'success', result);
        return { status: 'success', result };
      }

      case 'git commit and push': {
        const msg = args?.message || 'Automated commit';
        const tag = '[auto:cade]';
        const message = msg.includes(tag) ? msg : `${tag} ${msg}`;
        await execAsync('git add .');
        await execAsync(`git commit -m "${message}"`);
        const { stdout } = await execAsync('git push');
        const result = { output: stdout.trim() };
        await logCommand(command, args, 'success', result);
        return { status: 'success', result };
      }

      case 'package': {
        const results = [];
        for (const step of args?.steps || []) {
          const { command: subCmd, args: stepArgs } = step;
          const result = await cadeCommandRouter(subCmd, stepArgs);
          results.push({ command: subCmd, args: stepArgs, ...result });
        }
        const packagePath = path.resolve('memory', `package-output-${Date.now()}.json`);
        await writeFile(packagePath, JSON.stringify(results, null, 2), 'utf8');
        await logCommand(command, args, 'success', { outputPath: packagePath });
        return { status: 'success', result: results };
      }

      case 'retrieve logs': {
        const limit = args?.limit || 10;
        const logsRaw = await readFile(logPath, 'utf8');
        const lines = logsRaw.trim().split('\n').slice(-limit);
        const entries = lines.map(line => JSON.parse(line));
        return { status: 'success', result: entries };
      }

      default:
        const errorMsg = `Command "${command}" not recognized by Cade.`;
        await logCommand(command, args, 'error', { message: errorMsg });
        return { status: 'error', message: errorMsg };
    }
  } catch (err: any) {
    await logCommand(command, args, 'error', { message: err.message });
    return { status: 'error', message: err.message };
  }
}
