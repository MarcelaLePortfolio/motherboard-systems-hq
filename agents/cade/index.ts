import { exec } from "child_process";

export async function routeToCade(task: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const prompt = `Act as a DevOps assistant. Based on the task: "${task}", output the exact terminal command(s) to execute locally. Avoid any explanations—just the command(s).`;

    exec(`echo "${prompt}" | ollama run openchat:3.5-0106`, (err, stdout, stderr) => {
      if (err || stderr) return reject(stderr || err);

      const command = stdout.trim();
      if (!command.match(/[a-zA-Z0-9]/)) return reject("🛑 Cade blocked empty or non-textual LLM output.");

      exec(command, (execErr, execOut, execErrOut) => {
        if (execErr || execErrOut) return reject(`💥 Cade execution failed:\n${execErrOut || execErr}`);
        resolve(`🛠️ Cade executed:\n${command}\n\n📤 Output:\n${execOut}`);
      });
    });
  });
}
