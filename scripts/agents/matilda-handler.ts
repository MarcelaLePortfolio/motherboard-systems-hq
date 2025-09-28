import fetch from "node-fetch";

type Role = "system" | "user" | "assistant";
type ChatMessage = { role: Role; content: string };

const OLLAMA_HOST = "http://127.0.0.1:11434";  // ✅ match Ollama logs
const OLLAMA_MODEL = "llama3:8b";

const chatBuffers = new Map<string, ChatMessage[]>();

const MATILDA_SYSTEM_PROMPT = [
  "You are Matilda, a retro-futuristic executive assistant for Motherboard Systems HQ.",
  "Respond conversationally, concise but warm.",
  "If asked for file or automation tasks, delegate to Cade with a ```cade fenced JSON block."
].join("\n");

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
    body: JSON.stringify({ model: OLLAMA_MODEL, prompt: convoText, stream: false })
  });
  if (!resp.ok) {
    const text = await resp.text().catch(() => "");
    throw new Error(`Ollama error: HTTP ${resp.status} ${text}`);
  }
  const data: any = await resp.json();
  return data?.response || "";
}

function extractCadeTask(txt: string): { task: any | null; cleaned: string } {
  const fence = /```cade\s*([\s\S]*?)```/i;
  const m = txt.match(fence);
  if (!m) return { task: null, cleaned: txt.trim() };
  let task = null;
  try { task = JSON.parse(m[1]); } catch {}
  return { task, cleaned: txt.replace(fence, "").trim() };
}

async function callCade(command: string, payload: any): Promise<any> {
  try {
    const mod = await import("./cade");
    const router = (mod as any)?.cadeCommandRouter;
    return router ? await router(command, payload) : { status: "error", message: "no cadeCommandRouter" };
  } catch (err: any) {
    return { status: "error", message: err?.message || String(err) };
  }
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
  const { task, cleaned } = extractCadeTask(raw);

  buffer.push({ role: "assistant", content: cleaned });
  trimBuffer(buffer);

  const replies: string[] = [];
  if (cleaned) replies.push(cleaned);

  if (task?.command) {
    const cadeResult = await callCade(task.command, task.payload ?? {});
    replies.push("🛠 Cade • " + JSON.stringify(cadeResult));
  }

  return { replies };
}
