import fs from 'fs';
import { spawn } from 'node:child_process';

const child = spawn('npx', ['tsx', './scripts/agents/cade.ts'], {
  stdio: ['inherit', fs.openSync('logs/cade-out.log', 'a'), fs.openSync('logs/cade-error.log', 'a')],
  shell: true
});

child.on('exit', (code) => process.exit(code));
