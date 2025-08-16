import { exec } from "child_process";
import { log } from "../../utils/log";

interface InstallDepsInput {
  type: "install dependencies";
  tool: "bun" | "pnpm";
  packages: string[]; // e.g., ["typescript", "eslint"]
}

export async function installDepsWithCade(input: InstallDepsInput): Promise<{ status: string; message: string }> {
  const { tool, packages } = input;

  if (!["bun", "pnpm"].includes(tool)) {
    return { status: "error", message: `Unsupported tool: ${tool}` };
  }

  if (!packages || packages.length === 0) {
    return { status: "error", message: "No packages specified for installation." };
  }

  const command = `${tool} add ${packages.join(" ")}`;
  log(`📦 Installing dependencies using: ${command}`);

  return new Promise((resolve) => {
    exec(command, { cwd: process.cwd() }, (err, stdout, stderr) => {
      if (err) {
        log(`❌ Error during install: ${stderr}`);
        return resolve({ status: "error", message: stderr });
      }
      log(`✅ Install complete:\n${stdout}`);
      resolve({ status: "success", message: stdout });
    });
  });
}
