
import { spawn } from 'node:child_process';

const child = spawn('npx', ['tsx', './scripts/agents/cade.ts'], {
  stdio: 'inherit',
  shell: true
});

child.on('exit', (code) => process.exit(code));
