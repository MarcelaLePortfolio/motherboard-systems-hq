import fs from "fs";
import { runOllamaPrompt } from "../../shared/ollama";

export async function convertCodeWithOllama(args: { path: string }) {
  const filePath = args?.path;
  if (!filePath || !fs.existsSync(filePath)) {
    return { status: "error", message: "File not found: " + filePath };
  }
  const code = fs.readFileSync(filePath, "utf8");
  const prompt = `
You are a senior developer. Convert this code to another module system or type (e.g., JS → TS, CommonJS → ESM).

Output only the converted code.

\`\`\`ts
${code}
\`\`\`
`.trim();

  try {
    const converted = await runOllamaPrompt(prompt);
    return { status: "success", converted };
  } catch (err: any) {
    return { status: "error", message: err.message };
  }
}
