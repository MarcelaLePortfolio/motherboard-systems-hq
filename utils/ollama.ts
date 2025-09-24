import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

export async function callOllama(prompt: string): Promise<string> {
  try {
    const command = `/usr/local/bin/ollama run llama3:8b "${prompt}"`;
    const { stdout, stderr } = await execAsync(command, { timeout: 60_000 });

    if (stderr) {
      console.warn("⚠️ Ollama stderr:", stderr);
    }

    return stdout.trim() || "⚠️ No response from model.";
  } catch (err: any) {
    return `❌ Error calling Ollama: ${err.message || err}`;
  }
}
