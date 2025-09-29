import { fetch } from "undici";

export async function ollamaChat(convo: { role: string; content: string }[]): Promise<string> {
  console.log("🟢 ollamaFetch (undici) called with messages:", convo.length);

  const convoText = convo.map(m => `${m.role}: ${m.content}`).join("\n");
  console.log("�� Sending prompt to Ollama:", convoText.slice(0, 80) + "...");

  const resp = await fetch("http://127.0.0.1:11434/api/generate", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ model: "llama3:8b", prompt: convoText, stream: false })
  });

  const raw = await resp.text();
  console.log("🟢 Raw response length:", raw.length);

  try {
    const obj = JSON.parse(raw);
    if (obj.response) return obj.response.trim();
    return JSON.stringify(obj);
  } catch {
    return raw.trim() || "(no response)";
  }
}
