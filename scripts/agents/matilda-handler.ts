console.log("🔍 <0001FAC3> Matilda handler loaded from", import.meta.url);

import { MATILDA_SYSTEM_PROMPT } from "../../config/matilda-prompt";
import { getBuffer, trimBuffer } from "../memory/session-buffer";
import { ollamaChat } from "./ollama-fetch";

export async function handleMatildaMessage(
  sid: string,
  userText: string
): Promise<{ replies: string[] }> {
  console.log("🚩 <0001FAC3> Matilda handler ACTIVE (ollama mode)");

  try {
    const buffer = getBuffer(sid);
    buffer.push({ role: "user", content: userText });
    trimBuffer(buffer);

    console.log("🔎 <0001FAC3> About to call ollamaChat");
    const raw = await ollamaChat([
      { role: "system", content: MATILDA_SYSTEM_PROMPT },
      ...buffer,
    ]);

    buffer.push({ role: "assistant", content: raw });
    trimBuffer(buffer);

    return { replies: [raw] };
  } catch (err: any) {
    console.error("❌ <0001FAC3> Matilda handler caught error:", err);
    return { replies: ["⚠️ Matilda crashed: " + (err?.message || String(err))] };
  }
}
