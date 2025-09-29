console.log("🟢 Matilda handler ACTIVE v3 — using resp.text() only, no getReader");

type Role = "system" | "user" | "assistant";
type ChatMessage = { role: Role; content: string };

const OLLAMA_HOST = "http://127.0.0.1:11434";
const OLLAMA_MODEL = "llama3:8b";

const chatBuffers = new Map<string, ChatMessage[]>();
const MATILDA_SYSTEM_PROMPT = "You are Matilda, a retro-futuristic assistant.";

function getBuffer(sid: string): ChatMessage[] {
  if (!chatBuffers.has(sid)) chatBuffers.set(sid, []);
  return chatBuffers.get(sid)!;
}
function trimBuffer(buffer: ChatMessage[], max: number = 10) {
  while (buffer.length > max) buffer.shift();
}

async function ollamaChat(messages: ChatMessage[]): Promise<string> {
  const prompt = messages.map(m => `${m.role}: ${m.content}`).join("\n");

  const resp = await fetch(`${OLLAMA_HOST}/api/generate`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    // 🔑 explicitly disable streaming
    body: JSON.stringify({ model: OLLAMA_MODEL, prompt, stream: false })
  });

  const raw = await resp.text();

  // Some Ollama builds return JSON, others JSONL; handle both
  try {
    const parsed = JSON.parse(raw);
    if (parsed.response) return parsed.response.trim();
  } catch {
    let combined = "";
    for (const line of raw.split("\n")) {
      try {
        const obj = JSON.parse(line);
        if (obj.response) combined += obj.response;
      } catch { /* ignore */ }
    }
    if (combined) return combined.trim();
  }

  return raw.trim() || "(no response)";
}

export async function handleMatildaMessage(
  sid: string,
  userText: string
): Promise<{ replies: string[] }> {
  const buffer = getBuffer(sid);

  const convo: ChatMessage[] = [{ role: "system", content: MATILDA_SYSTEM_PROMPT }];
  convo.push(...buffer.slice(-10));
  convo.push({ role: "user", content: userText });

  buffer.push({ role: "user", content: userText });
  trimBuffer(buffer);

  const raw = await ollamaChat(convo);

  buffer.push({ role: "assistant", content: raw });
  trimBuffer(buffer);

  return { replies: [raw] };
}
