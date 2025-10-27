import { execSync } from "child_process";

/**
 * 🧠 ollamaPlan — uses local Ollama to interpret user intent.
 */
export async function ollamaPlan(prompt: string) {
  try {
    const result = execSync(`ollama run llama3 "${prompt}"`, { encoding: "utf8" });
    return result.trim();
  } catch (err: any) {
    return `⚠️ Ollama planning failed: ${err.message}`;
  }
}
