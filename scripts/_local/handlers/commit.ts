import { exec } from "child_process";

export function handleCommitTask(message: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const command = `git add . && git commit -m "${message}" && git push`;
    exec(command, (err, stdout, stderr) => {
      if (err) {
        return reject(`❌ Commit failed:\n${stderr}`);
      }
      resolve(`✅ Commit succeeded:\n${stdout}`);
    });
  });
}
