import { fetch } from "undici";

console.log("🧪 <0001FAC0> ollama-fetch.ts loaded in TEST MODE for Cade retest");

export async function ollamaChat(convo: { role: string; content: string }[]): Promise<string> {
  console.log("🧪 <0001FAC0> ollamaChat invoked, messages:", convo.length);
  
  // Instead of calling Ollama, simulate a parse failure
  throw new Error("💥 <0001FAC0> Simulated JSON parse error for Cade retest");
}
