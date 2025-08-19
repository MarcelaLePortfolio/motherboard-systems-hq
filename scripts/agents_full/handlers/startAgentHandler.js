import { exec } from "child_process";
import { promisify } from "util";
const execAsync = promisify(exec);

export default async function startAgentHandler(options) {
  try {
    const agentName = options?.name;
    const scriptPath = options?.script;
    if (!agentName || !scriptPath) throw new Error("Agent name or script path not provided");

    // Start agent with PM2
    const { stdout } = await execAsync(`pm2 start ${scriptPath} --name ${agentName} --interpreter bash`, { cwd: process.cwd() });

    // Optional: save PM2 list
    await execAsync("pm2 save", { cwd: process.cwd() });

    return { status: "started", agent: agentName, output: stdout.trim() };
  } catch (err) {
    return { error: err.message };
  }
}
