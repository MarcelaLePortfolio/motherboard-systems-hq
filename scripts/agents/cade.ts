import path from 'path';
import fs from 'fs';

const SAFE_ROOTS = [
  path.resolve('memory'),
  path.resolve('scripts/_local/memory'),
];

const chainStatePath = path.resolve('memory/agent_chain_state.json');

function isSafePath(filePath: string): boolean {
  const fullPath = path.resolve(filePath);
  return SAFE_ROOTS.some(safeRoot => fullPath.startsWith(safeRoot));
}

function readChainState() {
  try {
    const raw = fs.readFileSync(chainStatePath, 'utf8');
    return JSON.parse(raw);
  } catch (err) {
    return null;
  }
}

function writeChainState(data: any) {
  fs.writeFileSync(chainStatePath, JSON.stringify(data, null, 2), 'utf8');
}

export async function cadeCommandRouter(command: string, args: any = {}): Promise<any> {
  switch (command) {
    case 'write to file': {
      const { path: filePath, content } = args;
      if (!isSafePath(filePath)) {
        return { status: 'error', message: 'Unsafe file path.' };
      }

      try {
        fs.writeFileSync(filePath, content, 'utf8');
        return { status: 'success', message: `Wrote to ${filePath}` };
      } catch (err) {
        return { status: 'error', message: (err as Error).message };
      }
    }

    case 'start full task delegation cycle': {
      const chain = readChainState();
      if (!chain) {
        return { status: 'error', message: '❌ Could not parse chain state.' };
      }

      chain.tasks = [
        { id: 'T1', agent: 'effie', action: 'log', payload: 'Hello from Cade.' },
      ];

      writeChainState(chain);
      return { status: 'success', message: '✅ Task delegation chain written to memory.' };
    }

    default:
      return { status: 'error', message: `❌ Command "${command}" is not allowed.` };
  }
}
