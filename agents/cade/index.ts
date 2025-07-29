import { exec } from "child_process";
import fs from "fs";

// 🛡️ Blocklist of dangerous substrings
const BLOCKED_PATTERNS = [
  "rm ", "shutdown", "reboot", ":(){", "mkfs", "dd if", "kill", ">", "<",
  "curl ", "wget ", "scp ", "mv /", "chmod 777", "chown root"
];

function isDangerous(cmd: string): string | false {
  const lower = cmd.toLowerCase();
  for (const pattern of BLOCKED_PATTERNS) {
    if (lower.includes(pattern)) return pattern;
  }
  return false;
}

function logCommand(command: string) {
  const timestamp = new Date().toISOString();
  fs.appendFileSync("cade-execution.log", `${timestamp} :: ${command}\n`);
}

export async function routeToCade(task: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const prompt = `Act as a DevOps assistant. Based on the task: "${task}", output the exact terminal command(s) to execute locally. Avoid any explanations—just the command(s).`;

    exec(`echo "${prompt}" | ollama run openchat:3.5-0106`, (err, stdout, stderr) => {
      if (err || stderr) return reject(stderr || err);

      const command = stdout.trim();
      if (!command.match(/[a-zA-Z0-9]/)) return reject("🛑 Cade blocked empty or non-textual LLM output.");

      const unsafe = isDangerous(command);
      if (unsafe) return reject(`🛑 Cade blocked execution: dangerous pattern "${unsafe}" found.\n→ ${command}`);

      logCommand(command);

      exec(command, (execErr, execOut, execErrOut) => {
        if (execErr || execErrOut) return reject(`�� Cade execution failed:\n${execErrOut || execErr}`);
        resolve(`🛠️ Cade executed:\n${command}\n\n📤 Output:\n${execOut}`);
      });
    });
  });
}
