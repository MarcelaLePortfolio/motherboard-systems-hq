import { exec } from "child_process";

export function runShell(command: string): Promise<string> {
  return new Promise((resolve, reject) => {
    exec(command, { cwd: process.cwd(), env: process.env }, (error, stdout, stderr) => {
      if (error) {
        console.error(`❌ runShell error: ${stderr || error.message}`);
        reject(error);
      } else {
        resolve(stdout.trim());
      }
    });
  });
}
