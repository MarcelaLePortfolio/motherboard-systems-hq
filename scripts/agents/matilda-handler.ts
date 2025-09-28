/**
 * Matilda Handler
 * - Maintains lightweight per-session chat memory (last 5 turns)
 * - Calls local Ollama (http://localhost:11434/api/chat)
 * - Detects Cade delegation blocks in assistant output
 * - Routes tasks to Cade and returns results alongside the chat reply
 */

type Role = "system" | "user" | "assistant";
type ChatMessage = { role: Role; content: string };

const OLLAMA_HOST = process.env.OLLAMA_HOST || "http://localhost:11434";
const OLLAMA_MODEL = process.env.OLLAMA_MODEL || "llama3.1:8b";

// In-memory chat buffer: sid -> messages
const chatBuffers = new Map<string, ChatMessage[]>();

const MATILDA_SYSTEM_PROMPT = [
  "You are Matilda, a retro-futuristic executive assistant for Motherboard Systems HQ.",
  "You speak concisely, helpfully, and act as a local-first operator.",
  "",
  "If a user asks for any file or automation task, delegate to Cade using EXACTLY this format:",
  "```cade",
  '{ "command": "<one of: write to file | read file | delete file>", "payload": { /* params */ } }',
  "```",
  "",
  "Rules:",
  "• ONLY include one cade code block when delegation is required.",
  "• Outside of the cade code block, continue speaking conversationally.",
  "• Never include backticks inside the JSON. Keep it pure JSON.",
  "• Keep replies brief unless the user requests depth."
].join("\n");

function getBuffer(sid: string): ChatMessage[] {
  if (!chatBuffers.has(sid)) chatBuffers.set(sid, []);
  return chatBuffers.get(sid)!;
}

function trimBuffer(buffer: ChatMessage[], max: number = 10) {
  while (buffer.length > max) buffer.shift();
}

async function ollamaChat(messages: ChatMessage[]): Promise<string> {
  const resp = await fetch(`${OLLAMA_HOST}/api/chat`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      model: OLLAMA_MODEL,
      messages,
      stream: false
    })
  });

  if (!resp.ok) {
    const text = await resp.text().catch(() => "");
    throw new Error(`Ollama error: HTTP ${resp.status} ${text}`);
  }

  const data: any = await resp.json();
  const content = data?.message?.content ?? data?.response;
  if (!content || typeof content !== "string") {
    throw new Error("Ollama returned an unexpected payload.");
  }
  return content;
}

function extractCadeTask(assistantText: string): { task: any | null; cleaned: string } {
  const fence = /```cade\s*([\s\S]*?)```/i;
  const m = assistantText.match(fence);
  if (!m) return { task: null, cleaned: assistantText.trim() };

  let task: any = null;
  try {
    task = JSON.parse(m[1]);
  } catch {}
  const cleaned = assistantText.replace(fence, "").trim();
  return { task, cleaned };
}

async function callCade(command: string, payload: any): Promise<any> {
  try {
    const mod = await import("./cade");
    const router = (mod as any)?.cadeCommandRouter;
    if (typeof router !== "function") {
      throw new Error("cadeCommandRouter not found in ./cade");
    }
    const result = await router(command, payload);
    return result;
  } catch (err: any) {
    return { status: "error", message: err?.message || String(err) };
  }
}

export async function handleMatildaMessage(
  sid: string,
  userText: string
): Promise<{ replies: string[]; task?: any; cade_result?: any }> {
  const buffer = getBuffer(sid);

  const convo: ChatMessage[] = [{ role: "system", content: MATILDA_SYSTEM_PROMPT }];
  const recent = buffer.slice(-10);
  convo.push(...recent);
  convo.push({ role: "user", content: userText });

  buffer.push({ role: "user", content: userText });
  trimBuffer(buffer);

  const assistantRaw = await ollamaChat(convo);
  const { task, cleaned } = extractCadeTask(assistantRaw);

  buffer.push({ role: "assistant", content: cleaned });
  trimBuffer(buffer);

  const replies: string[] = [];
  if (cleaned) replies.push(cleaned);

  let cade_result: any = null;
  if (task && typeof task === "object" && typeof task.command === "string") {
    cade_result = await callCade(task.command, task.payload ?? {});
    const pretty =
      typeof cade_result === "object" ? JSON.stringify(cade_result) : String(cade_result);
    replies.push(`🛠 Cade • ${pretty}`);
  }

  return { replies, task: task ?? undefined, cade_result: cade_result ?? undefined };
}
