// <0001fbE0> ollamaPlan – enforces prefix naming for Cade-compatible actions
import { execSync } from "child_process";

export async function ollamaPlan(message: string) {
  try {
    const prompt = `
You are Matilda, Cade’s planning assistant.
Analyze the user's instruction and output ONLY one valid JSON object matching this schema:

{
  "action": "string",    // always start with file., dashboard., tasks., logs., or status.
  "params": {}
}

Ensure the "action" key follows Cade's naming rules (e.g., "file.create", "dashboard.refresh").
Command: "${message}"
`;
    const output = execSync(`ollama run llama3:8b "${prompt}"`, { encoding: "utf8" });
    const clean = output
      .replace(/```json|```/g, "")
      .replace(/^[^{]*({.*})[^}]*$/s, "$1")
      .trim();
    const json = JSON.parse(clean);
    return json;
  } catch (err: any) {
    console.error("<0001fbE0> ❌ ollamaPlan parse error:", err);
    return { action: "unknown", params: { message } };
  }
}
