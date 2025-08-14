import path from 'path';
import fs from 'fs';

const SAFE_ROOTS = [
  path.resolve('memory'),
  path.resolve('scripts/_local/memory'),
];

function isSafePath(filePath: string): boolean {
  const fullPath = path.resolve(filePath);
  return SAFE_ROOTS.some(safeRoot => fullPath.startsWith(safeRoot));
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

    // Add future commands here…

    default:
      return { status: 'error', message: `❌ Command "${command}" is not allowed.` };
  }
}
