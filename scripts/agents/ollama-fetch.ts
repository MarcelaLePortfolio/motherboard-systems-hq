import { fetch } from "undici";

console.log("🧪 <0001FAC0> ollama-fetch.ts in TEST FAIL MODE");

export async function ollamaChat(convo: { role: string; content: string }[]): Promise<string> {
  console.log("🧪 <0001FAC0> ollamaChat invoked, throwing hard fail");
  throw new Error("💥 <0001FAC0> HARD FAIL from ollama-fetch.ts");
}
