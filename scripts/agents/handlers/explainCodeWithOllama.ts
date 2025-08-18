import fs from "fs";
import { runOllamaPrompt } from "../../shared/ollama";

export async function explainCodeWithOllama(args: { path: string }) {
  const filePath = args?.path;
  if (!filePath || !fs.existsSync(filePath)) {
    return { status: "error", message: "File not found: " + filePath };
  }

  const code = fs.readFileSync(filePath, "utf8");

  // Prompt for concise, plain-language explanation
  const prompt = `
You are Matilda, a friendly assistant. Summarize the following TypeScript/JavaScript code
in short, plain language suitable for quick understanding by a human. Do NOT include any code snippets.

Code:
${code}
`.trim();

  try {
    const explanation = await runOllamaPrompt(prompt);
    return { status: "success", explanation };
  } catch (err: any) {
    return { status: "error", message: err.message };
  }
}
