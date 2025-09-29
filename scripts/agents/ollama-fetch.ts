import { fetch } from "undici";

console.log("🆕 LIVE MARKER <0001FAAA> ollama-fetch.ts loaded at", new Date().toISOString());

export async function ollamaChat(convo: { role: string; content: string }[]): Promise<string> {
  console.log("🆕 <0001FAAA> ollamaChat invoked, messages:", convo.length);
  const convoText = convo.map(m => `${m.role}: ${m.content}`).join("\n");

  const resp = await fetch("http://127.0.0.1:11434/api/generate", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ model: "llama3:8b", prompt: convoText, stream: false })
  });

  const raw = await resp.text();
  try {
    const obj = JSON.parse(raw);
    if (obj.response) return obj.response.trim();
    return JSON.stringify(obj);
  } catch {
    throw new Error("💥 <0001FAAA> JSON parse failed in ollama-fetch.ts");
  }
}
