import { exec } from "child_process";

export function handleInstallTask(pkg?: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const command = pkg ? `pnpm add ${pkg}` : `pnpm install`;
    exec(command, (err, stdout, stderr) => {
      if (err) {
        return reject(`❌ Install failed:\n${stderr}`);
      }
      resolve(`✅ Install succeeded:\n${stdout}`);
    });
  });
}
