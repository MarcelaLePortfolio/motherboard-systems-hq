import fs from 'fs';
import path from 'path';

export function atomicWriteFile(filePath: string, content: string): void {
  const tempPath = `${filePath}.tmp`;
  fs.writeFileSync(tempPath, content);
  fs.renameSync(tempPath, filePath);
}

export function atomicReadFile(filePath: string): string {
  return fs.existsSync(filePath) ? fs.readFileSync(filePath, 'utf-8') : '';
}
