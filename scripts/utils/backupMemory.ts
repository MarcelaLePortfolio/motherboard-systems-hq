import { execSync } from 'child_process';
import path from 'path';
import fs from 'fs';

export function backupMemoryFolder() {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const backupName = \`memory_backup_\${timestamp}.zip\`;
  const dest = path.resolve('backups');
  fs.mkdirSync(dest, { recursive: true });

  try {
    execSync(\`zip -r \${path.join(dest, backupName)} memory\`);
    console.log(\`📦 Backup created at: \${backupName}\`);
  } catch (err: any) {
    console.error('❌ Backup failed:', err.message);
  }
}
