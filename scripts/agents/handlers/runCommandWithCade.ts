import { exec } from 'child_process';
import util from 'util';

const execPromise = util.promisify(exec);

export async function runCommandWithCade(args: { command: string }) {
  if (!args?.command) {
    return { status: 'error', message: 'No command provided.' };
  }

  try {
    const { stdout, stderr } = await execPromise(args.command, { timeout: 30_000 });
    return {
      status: 'success',
      output: stdout.trim(),
      errorOutput: stderr.trim() || null,
    };
  } catch (err: any) {
    return {
      status: 'error',
      message: err.message,
      stderr: err.stderr?.toString(),
      stdout: err.stdout?.toString(),
    };
  }
}
