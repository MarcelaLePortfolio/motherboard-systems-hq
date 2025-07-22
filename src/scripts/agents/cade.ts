import { exec as execCallback } from 'child_process';
import { promises as fs } from 'fs';
import path from 'path';
import os from 'os';
import util from 'util';

const execAsync = util.promisify(execCallback);
const { readFile, writeFile, rename, unlink } = fs;

export async function cadeCommandRouter(command: string, args?: any) {
  switch (command.toLowerCase()) {
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

    case 'move file':
      try {
        const fromPath = path.resolve(args?.from);
        const toPath = path.resolve(args?.to);
        await rename(fromPath, toPath);
        return { status: 'success', result: { message: `Moved to ${toPath}` } };
      } catch (err: any) {
        return { status: 'error', message: err.message };
      }

    case 'delete file':
      try {
        const targetPath = path.resolve(args?.path);
        await unlink(targetPath);
        return { status: 'success', result: { message: `Deleted ${targetPath}` } };
      } catch (err: any) {
        return { status: 'error', message: err.message };
      }

    case 'open url':
      try {
        const url = args?.url;
        if (!url) throw new Error('Missing URL argument.');
        const opener = os.platform() === 'darwin' ? 'open' : os.platform() === 'win32' ? 'start ""' : 'xdg-open';
        await execAsync(`${opener} "${url}"`);
        return { status: 'success', result: { message: `Opened ${url}` } };
      } catch (err: any) {
        return { status: 'error', message: err.message };
      }

    case 'edit env':
      try {
        const envPath = path.resolve('.env.local');
        const envContent = await readFile(envPath, 'utf8');
        const lines = envContent.split('\n');
        const newVar = `${args?.key}=${args?.value}`;
        const updatedLines = lines.filter(line => !line.startsWith(`${args?.key}=`));
        updatedLines.push(newVar);
        await writeFile(envPath, updatedLines.join('\n'), 'utf8');
        return { status: 'success', result: { message: `Set ${args?.key} in .env.local` } };
      } catch (err: any) {
        return { status: 'error', message: err.message };
      }

    case 'git commit and push':
      try {
        const msg = args?.message || 'Automated commit';
        const tag = '[auto:cade]';
        const message = msg.includes(tag) ? msg : `${tag} ${msg}`;
        await execAsync('git add .');
        await execAsync(`git commit -m "${message}"`);
        const { stdout } = await execAsync('git push');
        return { status: 'success', result: { output: stdout.trim() } };
      } catch (err: any) {
        return { status: 'error', message: err.message };
      }

    case 'package':
      try {
        const results = [];
        for (const step of args?.steps || []) {
          const { command, args: stepArgs } = step;
          const result = await cadeCommandRouter(command, stepArgs);
          results.push(result);
        }
        return { status: 'success', result: results };
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
