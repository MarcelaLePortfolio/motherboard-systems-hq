import { exec } from "child_process";
import { promisify } from "util";
const execAsync = promisify(exec);

export default async function installDepsHandler(options) {
  const pkg = options?.package || "";
  const manager = options?.manager || "pnpm";
  const { stdout } = await execAsync(`${manager} add ${pkg}`, { cwd: process.cwd() });
  await execAsync(`git add . && git commit -m "Installed ${pkg} via Cade"`, { cwd: process.cwd() });
  return { status: "installed", package: pkg, output: stdout.trim() };
}
