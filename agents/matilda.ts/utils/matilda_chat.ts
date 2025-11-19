// <0001fb07> Matilda Chat Submodule — Direct Ollama Conversation
import { execSync } from "child_process";

export function chatWithOllama(prompt) {
  try {
    const command = `ollama run gemma:2b "You are Matilda, a friendly, natural AI assistant. Keep your tone casual and authentic. Respond to: ${prompt}"`;
    const output = execSync(command, { encoding: "utf8", stdio: ["pipe", "pipe", "ignore"] });
    return output.trim();
  } catch {
    return "💬 (fallback) I’m here, but can’t seem to connect to my brain right now.";
  }
}
