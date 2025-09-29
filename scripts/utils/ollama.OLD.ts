import { exec } from "child_process";

export async function callOllama(prompt: string, model: string = "llama3"): Promise<string> {
  return new Promise((resolve, reject) => {
    const escapedPrompt = prompt.replace(/"/g, '\\"');
    const command = `ollama run ${model} "${escapedPrompt}"`;

    exec(command, { maxBuffer: 1024 * 500 }, (error, stdout, stderr) => {
      if (error) {
        console.error("❌ Ollama error:", error);
        return reject(stderr || error.message);
      }

      resolve(stdout.trim());
    });
  });
}