import { exec } from "child_process";
export function handleInstallTask(pkg) {
    return new Promise((resolve, reject) => {
        const command = pkg ? `pnpm add ${pkg}` : `pnpm install`;
        exec(command, (err, stdout, stderr) => {
            if (err) {
                return reject(`❌ Install failed:
${stderr}`);
            }
            resolve(`✅ Install succeeded:
${stdout}`);
        });
    });
}
