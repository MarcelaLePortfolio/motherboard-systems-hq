import { exec } from "child_process";

export function handleCommitTask(message) {
  return new Promise((resolve, reject) => {
    const safeMessage = message.replace(/"/g, '\\"');
    const command = `git add . && git commit -m "${safeMessage}" && git push`;
    exec(command, (err, stdout, stderr) => {
      if (err) {
        reject(`❌ Commit failed:\n${stderr}`);
      } else {
        resolve(`✅ Commit succeeded:\n${stdout}`);
      }
    });
  });
}
