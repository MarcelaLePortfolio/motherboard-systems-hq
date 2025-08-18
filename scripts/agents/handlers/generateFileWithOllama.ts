import fs from "fs";
import path from "path";
import { runOllamaPrompt } from "../../shared/ollama";

export async function generateFileWithOllama(args: {
  path: string;
  type?: string;
  context?: string;
}) {
  const { path: filePath, type = "utility script", context = "" } = args || {};
  const filename = path.basename(filePath);

  const prompt = `
You are an expert developer. Generate a ${type} named ${filename}.
Only output the code. Do not include comments or explanations.
${context ? `\nContext:\n${context}` : ""}
`.trim();

  try {
    const code = await runOllamaPrompt(prompt);
    fs.writeFileSync(filePath, code);
    return { status: "success", message: `File written to ${filePath}` };
  } catch (err: any) {
    return { status: "error", message: err.message };
  }
}
