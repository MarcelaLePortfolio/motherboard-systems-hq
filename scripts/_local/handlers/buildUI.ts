import { exec } from "child_process";

export function handleBuildUITask(command?: string): Promise<string> {
  return new Promise((resolve, reject) => {
    // Use a provided command if given; otherwise default to "pnpm run build"
    const cmd = command && command.trim().length > 0 ? command : "pnpm run build";
    exec(cmd, { env: process.env }, (err, stdout, stderr) => {
      if (err) {
        return reject(`❌ UI build failed (command: ${cmd}):\n${stderr || stdout}`);
      }
      resolve(`✅ UI build succeeded (command: ${cmd}):\n${stdout}`);
    });
  });
}
