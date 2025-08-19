import { exec } from "node:child_process";
export async function runScriptWithCade(args: { command: string }) {
  return new Promise((resolve) => {
    exec(args.command, (err, stdout, stderr) => {
      if (err) resolve({ status: "error", message: stderr || err.message });
      else resolve({ status: "success", output: stdout.trim() });
    });
  });
}
