import { exec } from "node:child_process";
export async function installDepsWithCade(args: { packages: string[] }) {
  const command = `pnpm add ${args.packages.join(" ")}`;
  return new Promise((resolve) => {
    exec(command, (err, stdout, stderr) => {
      if (err) resolve({ status: "error", message: stderr || err.message });
      else resolve({ status: "success", output: stdout.trim() });
    });
  });
}
