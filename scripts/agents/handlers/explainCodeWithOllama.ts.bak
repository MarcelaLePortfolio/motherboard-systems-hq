cp scripts/agents/handlers/explainCodeWithOllama.ts scripts/agents/handlers/explainCodeWithOllama.ts.bak
import fs from "fs";
import { runOllamaPrompt } from "../../shared/ollama";

export async function explainCodeWithOllama(args: { path: string }) {
  const filePath = args?.path;
  if (!filePath || !fs.existsSync(filePath)) {
    return { status: "error", message: "File not found: " + filePath };
  }

  const code = fs.readFileSync(filePath, "utf8");

  const prompt =
    "You are a senior developer. Explain the following code file.\n\n" +
    "Focus on:\n" +
    "• How it works\n" +
    "• Its main functions and components\n" +
    "• Any notable implementation details\n\n" +
    "Only provide the explanation. Do not repeat the code.\n\n" +
    "```ts\n" +
    code +
    "\n```";

  try {
    const explanation = await runOllamaPrompt(prompt);
    return { status: "success", explanation };
  } catch (err: any) {
    return { status: "error", message: err.message };
  }
}
