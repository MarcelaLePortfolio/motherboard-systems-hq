import { fetch } from "undici";

console.log("🆕 LIVE <0001FAB0> ollama-fetch.ts restored at", new Date().toISOString());

export async function ollamaChat(convo: { role: string; content: string }[]): Promise<string> {
  console.log("🆕 <0001FAB0> ollamaChat invoked, messages:", convo.length);
  const convoText = convo.map(m => `${m.role}: ${m.content}`).join("\n");

  const resp = await fetch("http://127.0.0.1:11434/api/generate", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ model: "llama3:8b", prompt: convoText, stream: false })
  });

  const raw = await resp.text();
  try {
    const obj = JSON.parse(raw);
    return obj.response?.trim() || JSON.stringify(obj);
  } catch (err) {
    console.error("💥 <0001FAB0> JSON parse failed in ollama-fetch.ts", err);
    return raw.trim() || "(no response)";
  }
}
