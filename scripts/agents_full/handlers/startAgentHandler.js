import { exec } from "child_process";
import { promisify } from "util";
const execAsync = promisify(exec);

export default async function startAgentHandler(options) {
  const agentName = options?.name;
  const scriptPath = options?.script;
  const { stdout } = await execAsync(`pm2 start ${scriptPath} --name ${agentName} --interpreter bash`, { cwd: process.cwd() });
  await execAsync("pm2 save", { cwd: process.cwd() });
  return { status: "started", agent: agentName, output: stdout.trim() };
}
