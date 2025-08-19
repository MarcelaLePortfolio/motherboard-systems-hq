import { exec } from "child_process";
import { promisify } from "util";
const execAsync = promisify(exec);

export default async function runScriptHandler(options) {
  try {
    const command = options?.command;
    if (!command) throw new Error("No command provided");

    const { stdout, stderr } = await execAsync(command, { cwd: process.cwd() });

    return { status: "executed", command, output: stdout.trim(), errorOutput: stderr.trim() };
  } catch (err) {
    return { error: err.message };
  }
}
