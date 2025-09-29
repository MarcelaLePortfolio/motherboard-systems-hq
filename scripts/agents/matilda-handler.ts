import fetch from "node-fetch";

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
  const convoText = messages.map(m => `${m.role.toUpperCase()}: ${m.content}`).join("\n");
  const resp = await fetch(`${OLLAMA_HOST}/api/generate`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ model: OLLAMA_MODEL, prompt: convoText })
  });
  const raw = await resp.text();
  let content = "";
  for (const line of raw.split("\n")) {
    if (!line.trim()) continue;
    try {
      const obj = JSON.parse(line);
      if (obj.response) content += obj.response;
    } catch {}
  }
  return content.trim();
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
