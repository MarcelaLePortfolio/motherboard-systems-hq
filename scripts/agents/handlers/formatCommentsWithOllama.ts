import fs from "fs";
import { runOllamaPrompt } from "../../shared/ollama";

export async function formatCommentsWithOllama(args: { path: string }) {
  const filePath = args?.path;
  if (!filePath || !fs.existsSync(filePath)) {
    return { status: "error", message: "File not found: " + filePath };
  }
  const code = fs.readFileSync(filePath, "utf8");
  const prompt = `
You are a senior developer. Reformat all comments in this code for clarity, conciseness, and style consistency.

Output the full code including reformatted comments.

\`\`\`ts
${code}
\`\`\`
`.trim();

  try {
    const formatted = await runOllamaPrompt(prompt);
    return { status: "success", formatted };
  } catch (err: any) {
    return { status: "error", message: err.message };
  }
}
