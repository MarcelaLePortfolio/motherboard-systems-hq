import { createHash } from 'crypto';
import fs from 'fs';

export function sha256String(s: string): string {
  return createHash('sha256').update(s, 'utf8').digest('hex');
}

export function sha256File(path: string): string {
  const buf = fs.readFileSync(path);
  return createHash('sha256').update(buf).digest('hex');
}
