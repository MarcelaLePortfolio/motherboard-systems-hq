import fs from "fs";
import { runOllamaPrompt } from "../../shared/ollama";

export async function convertCodeWithOllama(args: { path: string }) {
  const filePath = args?.path;
  if (!filePath || !fs.existsSync(filePath)) {
    return { status: "error", message: "File not found: " + filePath };
  }

  const code = fs.readFileSync(filePath, "utf8");

  // Prompt for converting code to another language or format
  const prompt = `
You are a senior developer. Convert the following TypeScript/JavaScript code
to a different language or format as requested. Keep formatting clean
and ensure correctness. Only output the converted code.

Code:
${code}
`.trim();

  try {
    const converted = await runOllamaPrompt(prompt);
    return { status: "success", converted };
  } catch (err: any) {
    return { status: "error", message: err.message };
  }
}