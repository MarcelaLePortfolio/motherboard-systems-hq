// <0001fbD3> ollamaPlan – force strict JSON response with fallback
import { execSync } from "child_process";

export async function ollamaPlan(message: string) {
  try {
    const prompt = `
You are Matilda, a planning assistant for Cade.
Your ONLY response must be a single valid JSON object, nothing else.
Follow this exact schema:
{"action": "string", "params": {}}

Command: "${message}"
`;
    const output = execSync(`ollama run llama3:8b "${prompt}"`, { encoding: "utf8" });
    const clean = output
      .replace(/^[^{]*({.*})[^}]*$/s, "$1")  // extract first JSON block
      .replace(/```json|```/g, "")
      .trim();

    const json = JSON.parse(clean);
    return json;
  } catch (err: any) {
    console.error("<0001fbD3> ❌ ollamaPlan parse error:", err);
    return { action: "unknown", params: { message } };
  }
}
