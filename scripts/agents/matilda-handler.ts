import { MATILDA_SYSTEM_PROMPT } from "../../config/matilda-prompt";
import { getBuffer, trimBuffer } from "../memory/session-buffer";
import { ollamaChat } from "./ollama-fetch";

type ChatMessage = { role: string; content: string };

export async function handleMatildaMessage(
  sid: string,
  userText: string
): Promise<{ replies: string[] }> {
  console.log("🟢 Matilda handler is using ollama-fetch.ts ✅");

  try {
    const buffer = getBuffer(sid);
    buffer.push({ role: "user", content: userText });
    trimBuffer(buffer);

    const raw = await ollamaChat([
      { role: "system", content: MATILDA_SYSTEM_PROMPT },
      ...buffer,
    ]);

    buffer.push({ role: "assistant", content: raw });
    trimBuffer(buffer);

    return { replies: [raw] };
  } catch (err: any) {
    console.error("❌ Matilda handler crashed:", err);
    return { replies: ["⚠️ Matilda crashed: " + (err?.message || String(err))] };
  }
}

// 🧩 Added by <0001f9f9> — self-maintenance hooks
if (/reinstall|reset|rebuild/i.test(userText)) {
  return {
    replies: ["🧹 Running full clean & reinstall (dev:clean)…"],
    task: { command: "dev:clean" }
  };
}

if (/restart|reload|fresh|boot/i.test(userText)) {
  return {
    replies: ["🔄 Restarting server fresh (dev:fresh)…"],
    task: { command: "dev:fresh" }
  };
}
