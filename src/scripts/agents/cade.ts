import { exec as execCallback } from 'child_process';
import { promises as fs } from 'fs';
import path from 'path';
import os from 'os';
import util from 'util';

const execAsync = util.promisify(execCallback);
const { readFile, writeFile, rename, unlink } = fs;

const ALLOWED_COMMANDS = new Set([
  'read file',
  'write to file',
  'launch script',
  'move file',
  'delete file',
  'open url',
  'git commit and push',
  'package'
]);

function isPathSafe(p: string) {
  return !p.includes('..') && !p.includes('*') && !p.startsWith('/') && !p.startsWith('~');
}

function isUrlSafe(url: string) {
  return !url.startsWith('file://') && !url.includes('localhost') && !/^(127|10|192\.168)\./.test(url);
}

export async function cadeCommandRouter(command: string, args?: any) {
  const normalizedCommand = command.toLowerCase();

  if (!ALLOWED_COMMANDS.has(normalizedCommand)) {
    return {
      status: 'error',
      message: `❌ Command "${command}" is not allowed.`
    };
  }

  switch (normalizedCommand) {
    case 'read file':
      try {
        const filepath = path.resolve(args?.path || 'scripts', 'README.md');
        if (!isPathSafe(filepath)) throw new Error('Unsafe file path.');
        const content = await readFile(filepath, 'utf8');
        return { status: 'success', result: { content } };
      } catch (err: any) {
        return { status: 'error', message: err.message };
      }

    case 'write to file':
      try {
        const filepath = path.resolve(args?.path || 'memory', 'agent_notes.txt');
        if (!isPathSafe(filepath)) throw new Error('Unsafe file path.');
        const content = args?.content || 'Hello from Cade!\n';
        await writeFile(filepath, content, 'utf8');
        return { status: 'success', result: { message: `Wrote to ${filepath}` } };
      } catch (err: any) {
        return { status: 'error', message: err.message };
      }

    case 'launch script':
      try {
        const filepath = path.resolve(args?.path || 'scripts', 'test.sh');
        if (!isPathSafe(filepath)) throw new Error('Unsafe file path.');
        const { stdout } = await execAsync(`bash "${filepath}"`);
        return { status: 'success', result: { output: stdout.trim() } };
      } catch (err: any) {
        return { status: 'error', message: err.message };
      }

    case 'move file':
      try {
        const fromPath = path.resolve(args?.from);
        const toPath = path.resolve(args?.to);
        if (!isPathSafe(fromPath) || !isPathSafe(toPath)) throw new Error('Unsafe file path.');
        await rename(fromPath, toPath);
        return { status: 'success', result: { message: `Moved to ${toPath}` } };
      } catch (err: any) {
        return { status: 'error', message: err.message };
      }

    case 'delete file':
      try {
        const targetPath = path.resolve(args?.path);
        if (!isPathSafe(targetPath)) throw new Error('Unsafe file path.');
        await unlink(targetPath);
        return { status: 'success', result: { message: `Deleted ${targetPath}` } };
      } catch (err: any) {
        return { status: 'error', message: err.message };
      }

    case 'open url':
      try {
        const url = args?.url;
        if (!url || !isUrlSafe(url)) throw new Error('Unsafe or missing URL.');
        const opener = os.platform() === 'darwin' ? 'open' : os.platform() === 'win32' ? 'start ""' : 'xdg-open';
        await execAsync(`${opener} "${url}"`);
        return { status: 'success', result: { message: `Opened ${url}` } };
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
