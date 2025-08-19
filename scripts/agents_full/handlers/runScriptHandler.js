import { exec } from "child_process";
import { promisify } from "util";
const execAsync = promisify(exec);

export default async function runScriptHandler(options) {
    const command = options?.command || "";
    const { stdout, stderr } = await execAsync(command, { cwd: process.cwd() });
    return { status: "executed", command, output: stdout.trim(), errorOutput: stderr.trim() };
}
