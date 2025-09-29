import { MATILDA_SYSTEM_PROMPT } from "../../config/matilda-prompt";
import { getBuffer, trimBuffer } from "../memory/session-buffer";
import { ollamaChat } from "./ollama-fetch";

type ChatMessage = { role: string; content: string };

export async function handleMatildaMessage(
  sid: string,
  userText: string
): Promise<{ replies: string[]; task?: { command: string } }> {
  console.log("<0001f7e2> Matilda handler ACTIVE (with self-heal hooks)");

  try {
    // 🧹 Auto-maintenance detection on userText (if asked directly)
    if (/reinstall|reset|rebuild/i.test(userText)) {
      return {
        replies: ["<0001f9f9> Running full clean & reinstall (dev:clean)…"],
        task: { command: "dev:clean" }
      };
    }
    if (/restart|reload|fresh|boot/i.test(userText)) {
      return {
        replies: ["🔄 Restarting server fresh (dev:fresh)…"],
        task: { command: "dev:fresh" }
      };
    }

    // 🗂️ Normal conversation flow
    const buffer = getBuffer(sid);
    buffer.push({ role: "user", content: userText });
    trimBuffer(buffer);

    let raw: string;
    try {
      raw = await ollamaChat([
        { role: "system", content: MATILDA_SYSTEM_PROMPT },
        ...buffer,
      ]);
    } catch (err: any) {
      console.error("❌ ollamaChat crashed:", err);

      // 🚑 Self-healing error detection
      const msg = String(err?.message || "");
      if (msg.includes("getReader")) {
        return {
          replies: ["⚠️ I detected a getReader bug. Triggering a fresh restart (dev:fresh)…"],
          task: { command: "dev:fresh" }
        };
      }
      if (msg.includes("Unexpected non-whitespace") || msg.includes("JSON")) {
        return {
          replies: ["⚠️ JSON parse failure detected. Running full clean & reinstall (dev:clean)…"],
          task: { command: "dev:clean" }
        };
      }

      return { replies: ["⚠️ Matilda crashed: " + msg] };
    }

    buffer.push({ role: "assistant", content: raw });
    trimBuffer(buffer);

    return { replies: [raw] };
  } catch (err: any) {
    console.error("❌ Matilda handler crashed:", err);
    return { replies: ["⚠️ Matilda crashed: " + (err?.message || String(err))] };
  }
}
