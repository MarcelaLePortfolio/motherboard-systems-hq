console.log("🔍 <0001FAC4> Matilda handler loaded from", import.meta.url);

import { MATILDA_SYSTEM_PROMPT } from "../../config/matilda-prompt";
import { getBuffer, trimBuffer } from "../memory/session-buffer";
import { ollamaChat } from "./ollama-fetch";

export async function handleMatildaMessage(
  sid: string,
  userText: string
): Promise<{ replies: string[]; task?: { command: string } }> {
  console.log("🚩 <0001FAC4> Matilda handler ACTIVE (ollama + self-heal mode)");

  try {
    const buffer = getBuffer(sid);
    buffer.push({ role: "user", content: userText });
    trimBuffer(buffer);

    console.log("🔎 <0001FAC4> About to call ollamaChat");
    const raw = await ollamaChat([
      { role: "system", content: MATILDA_SYSTEM_PROMPT },
      ...buffer,
    ]);

    buffer.push({ role: "assistant", content: raw });
    trimBuffer(buffer);

    return { replies: [raw] };
  } catch (err: any) {
    const msg = String(err?.message || "");
    console.error("❌ <0001FAC4> Matilda handler caught error:", msg);
    console.error("📍 Crash stack:", err?.stack);

    // 🚑 Self-heal delegation
    if (msg.includes("getReader")) {
      return {
        replies: [
          "⚠️ <0001FAC4> Detected getReader bug → triggering Cade: dev:fresh"
        ],
        task: { command: "dev:fresh" }
      };
    }
    if (msg.includes("JSON parse") || msg.includes("Unexpected")) {
      return {
        replies: [
          "⚠️ <0001FAC4> Detected JSON parse failure → triggering Cade: dev:clean"
        ],
        task: { command: "dev:clean" }
      };
    }

    // Default: report crash
    return { replies: ["⚠️ Matilda crashed: " + msg] };
  }
}
