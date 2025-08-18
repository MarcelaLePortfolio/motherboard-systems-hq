import fs from "fs";
import { runOllamaPrompt } from "../../shared/ollama";

export async function summarizeWithOllama(args: { path: string }) {
  const { path } = args || {};
  if (!path || !fs.existsSync(path)) {
    return { status: "error", message: "File not found: " + path };
  }

  const code = fs.readFileSync(path, "utf8");

  const prompt =
    "You are a senior developer. Summarize the following code file.\n\n" +
    "Focus on:\n" +
    "• What the code does\n" +
    "• Its main components or functions\n" +
    "• Any interesting implementation details\n\n" +
    "Only include the summary. Do not repeat the code.\n\n" +
    "```ts\n" +
    code +
    "\n```";

  try {
    const summary = await runOllamaPrompt(prompt);
    return { status: "success", summary };
  } catch (err) {
    return { status: "error", message: err.message };
  }
}
