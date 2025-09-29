import { MATILDA_SYSTEM_PROMPT } from "../../config/matilda-prompt";
import { getBuffer, trimBuffer } from "../memory/session-buffer";
import { ollamaChat } from "./ollama-fetch";

type ChatMessage = { role: string; content: string };

export async function handleMatildaMessage(
  sid: string,
  userText: string
): Promise<{ replies: string[] }> {
  console.log("🟢 Matilda handler entrypoint hit"); // debug marker
  try {
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
      console.error(err?.stack);
      return { replies: ["⚠️ ollamaChat crashed: " + (err?.message || String(err))] };
    }

    buffer.push({ role: "assistant", content: raw });
    trimBuffer(buffer);

    return { replies: [raw] };
  } catch (err: any) {
    console.error("❌ Matilda handler crashed:", err);
    console.error(err?.stack);
    return { replies: ["⚠️ Matilda crashed: " + (err?.message || String(err))] };
  }
}
