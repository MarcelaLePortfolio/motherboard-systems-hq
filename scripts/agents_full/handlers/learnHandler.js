import fs from "fs";
import path from "path";

export default async function learnHandler(options) {
  const docPath = options?.docPath;
  if (!docPath || !fs.existsSync(docPath)) {
    throw new Error(`Documentation file not found: ${docPath}`);
  }

  const content = fs.readFileSync(docPath, "utf-8");

  // TODO: Integrate Ollama / SQLite ingestion here
  // Placeholder: return success and content length
  return { status: "learned", docPath, length: content.length };
}
