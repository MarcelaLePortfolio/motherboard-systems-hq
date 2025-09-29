import { fetch } from "undici";

export async function ollamaChat(convo: { role: string; content: string }[]): Promise<string> {
  console.log("🟢 ollamaFetch (undici) called with messages:", convo.length);

  const convoText = convo.map(m => `${m.role}: ${m.content}`).join("\n");
  console.log("�� Sending prompt to Ollama:", convoText.slice(0, 80) + "...");

  let resp: Response;
  try {
    resp = await fetch("http://127.0.0.1:11434/api/generate", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ model: "llama3:8b", prompt: convoText })
    });
  } catch (err) {
    console.error("❌ Fetch to Ollama failed:", err);
    throw err;
  }

  console.log("🟢 Ollama responded with status:", resp.status);

  let raw: string;
  try {
    raw = await resp.text();
    console.log("🟢 Raw response length:", raw.length);
  } catch (err) {
    console.error("❌ Failed to read resp.text():", err);
    throw err;
  }

  let combined = "";
  for (const line of raw.split("\n")) {
    if (!line.trim()) continue;
    try {
      const obj = JSON.parse(line);
      if (obj.response) combined += obj.response;
    } catch {
      console.warn("⚠️ Failed to parse line:", line);
    }
  }
  return combined.trim() || raw.trim() || "(no response)";
}
