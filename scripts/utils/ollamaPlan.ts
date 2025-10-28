import { execSync } from "child_process";

/**
 * 🧠 Cade Reasoning Layer — uses Ollama to plan multi-step actions.
 * Input:  task description or message
 * Output: short JSON plan { action: string, params: object }
 */
export async function ollamaPlan(prompt: string): Promise<{ action: string; params: any }> {
  try {
    const raw = execSync(`ollama run mistral "Generate a JSON plan for: ${prompt}"`, { encoding: "utf8" });
    const match = raw.match(/\{[\s\S]*\}/);
    if (match) return JSON.parse(match[0]);
    return { action: "unknown", params: { note: "No structured output" } };
  } catch (err: any) {
    console.error("❌ ollamaPlan error:", err.message);
    return { action: "error", params: { message: err.message } };
  }
}
