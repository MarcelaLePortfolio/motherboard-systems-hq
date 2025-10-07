// <0001fbD8> ollamaChat – neutral conversational response via Ollama
import { execSync } from "child_process";

export async function ollamaChat(message: string) {
  try {
    const prompt = `You are Matilda, a helpful assistant. Reply conversationally and directly to the user.
User: "${message}"
Matilda:`;
    const output = execSync(`ollama run llama3:8b "${prompt}"`, { encoding: "utf8" });
    const clean = output.replace(/^(Matilda:|User:)?/gi, "").trim();
    return clean;
  } catch (err: any) {
    console.error("<0001fbD8> ❌ ollamaChat error:", err);
    return "I'm sorry, I couldn't think of a response just now.";
  }
}
