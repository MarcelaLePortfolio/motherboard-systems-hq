import { exec } from 'child_process';
import path from 'path';

export async function startAgentWithPM2(args: { agent: string }) {
  const { agent } = args;
  if (!agent) return { status: 'error', message: 'No agent name provided.' };

  const launchScript = path.resolve(`scripts/_local/agent-runtime/launch-${agent.toLowerCase()}.ts`);
  const command = `pm2 start "tsx" -- ${launchScript} --name ${agent}`;

  return new Promise((resolve) => {
    exec(command, { cwd: process.cwd() }, (err, stdout, stderr) => {
      if (err) {
        return resolve({ status: 'error', message: stderr });
      }
      resolve({ status: 'success', message: stdout });
    });
  });
}
