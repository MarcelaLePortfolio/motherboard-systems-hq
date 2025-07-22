import { exec } from "child_process";
import { isBlocked } from "./ideologyFilter.js";

export async function askBrain(input: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const prompt = `Act as a helpful local AI. Given the task: "${input}", output the exact shell command or local file operation that should be performed to complete it. Do not include explanations.`;

    exec(`echo '${prompt}' | ollama run openchat:3.5-0106`, (err, stdout, stderr) => {
      if (err || stderr) return reject(stderr || err);

      const output = stdout.trim();
      const blockedFlag = isBlocked(output);

      if (blockedFlag) {
        return reject(\`🛑 Effie blocked LLM output due to ideological term: "\${blockedFlag}"\n→ \${output}\`);
      }

      if (!output.match(/[a-zA-Z0-9]/)) return reject("🛑 Effie blocked empty or non-textual LLM output.");

      resolve(output);
    });
  });
}
