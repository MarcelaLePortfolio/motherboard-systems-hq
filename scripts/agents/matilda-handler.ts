import { MATILDA_SYSTEM_PROMPT } from "../../config/matilda-prompt";
import { getBuffer, trimBuffer } from "../memory/session-buffer";

type ChatMessage = { role: string; content: string };

// Minimal Ollama chat using fetch + resp.text()
// replaced by local helper
import { ollamaChat } from "./ollama-fetch";

//async function ollamaChat(convo: ChatMessage[]): Promise<string> {
  const convoText = convo.map(m => `${m.role}: ${m.content}`).join("\n");
  const resp = await fetch("http://127.0.0.1:11434/api/generate", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ model: "llama3:8b", prompt: convoText })
  });

  const raw = await resp.text();
  let combined = "";
  for (const line of raw.split("\n")) {
    if (!line.trim()) continue;
    try {
      const obj = JSON.parse(line);
      if (obj.response) combined += obj.response;
    } catch { /* ignore parse errors */ }
  }
  return combined.trim() || raw.trim() || "(no response)";
}

export async function handleMatildaMessage(
  sid: string,
  userText: string
): Promise<{ replies: string[] }> {
  console.log("🟢 Matilda handler entrypoint hit"); // debug marker
  try {
    const buffer = getBuffer(sid);
    buffer.push({ role: "user", content: userText });
    trimBuffer(buffer);

    const raw = await ollamaChat([
      { role: "system", content: MATILDA_SYSTEM_PROMPT },
      ...buffer
    ]);

    buffer.push({ role: "assistant", content: raw });
    trimBuffer(buffer);

    return { replies: [raw] };
  } catch (err: any) {
    console.error("❌ Matilda handler crashed:", err);
    console.error(err?.stack);
    return { replies: ["⚠️ Matilda crashed: " + (err?.message || String(err))] };
  }
}
