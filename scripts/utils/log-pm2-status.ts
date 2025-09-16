// scripts/utils/log-pm2-status.ts
import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';

try {
  const output = execSync('pm2 jlist', { encoding: 'utf8' });
  const parsed = JSON.parse(output).map((proc: any) => ({
    name: proc.name,
    pid: proc.pid,
    status: proc.pm2_env.status,
    memory: proc.monit.memory,
    cpu: proc.monit.cpu,
    uptime: proc.pm2_env.pm_uptime,
  }));

  const logPath = path.resolve('logs/pm2-status.json');
  fs.writeFileSync(logPath, JSON.stringify(parsed, null, 2), 'utf8');
  console.log(`✅ PM2 status written to ${logPath}`);
} catch (err: any) {
  console.error('❌ Failed to fetch PM2 status:', err.message);
}
