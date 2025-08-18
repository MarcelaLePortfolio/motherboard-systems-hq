import fs from "fs";
import { runOllamaPrompt } from "../../shared/ollama";

export async function commentCodeWithOllama(args: { path: string }) {
  const filePath = args?.path;
  if (!filePath || !fs.existsSync(filePath)) {
    return { status: "error", message: "File not found: " + filePath };
  }

  const code = fs.readFileSync(filePath, "utf8");

  // Prompt for concise, human-readable inline comments
  const prompt = `
You are Matilda, a friendly assistant. Add inline comments to the following TypeScript/JavaScript code.
- Keep comments short and clear.
- Do NOT include full code blocks in the output.

Code:
${code}
`.trim();

  try {
    const comments = await runOllamaPrompt(prompt);
    return { status: "success", comments };
  } catch (err: any) {
    return { status: "error", message: err.message };
  }
}