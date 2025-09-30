console.log("🔍 <0001FAC4> Matilda handler loaded from", import.meta.url);
import { cadeCommandRouter } from "../agents/cade";
console.log("<0001FB15> [Matilda] cadeCommandRouter type:", typeof cadeCommandRouter);
console.log("<0001FB1B> [Matilda] cadeCommandRouter source:", cadeCommandRouter.toString().slice(0,200));

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
        try {
          const cadeResult = await cadeCommandRouter("dev:fresh");
          console.log("<0001FB22> [Matilda] Cade dev:fresh returned:", cadeResult);
          return { replies: ["⚠️ <0001FAC4> Detected getReader bug → triggering Cade: dev:fresh"], task: { command: "dev:fresh" }, cadeResult };
        } catch (err) {
          console.error("<0001FB22> [Matilda] Cade dev:fresh FAILED:", err);
          return { replies: ["⚠️ <0001FAC4> Cade dev:fresh FAILED"], task: { command: "dev:fresh" }, cadeResult: { status: "error", message: String(err?.message || err) } };
        }
      return {
        replies: [
          "⚠️ <0001FAC4> Detected JSON parse failure → triggering Cade: dev:clean"
        try {
          const cadeResult = await cadeCommandRouter("dev:clean");
          console.log("<0001FB22> [Matilda] Cade dev:clean returned:", cadeResult);
          return { replies: ["⚠️ <0001FAC4> Detected JSON parse failure → triggering Cade: dev:clean"], task: { command: "dev:clean" }, cadeResult };
        } catch (err) {
          console.error("<0001FB22> [Matilda] Cade dev:clean FAILED:", err);
          return { replies: ["⚠️ <0001FAC4> Cade dev:clean FAILED"], task: { command: "dev:clean" }, cadeResult: { status: "error", message: String(err?.message || err) } };
        }
    // Default: report crash
    return { replies: ["⚠️ Matilda crashed: " + msg] };
  }
}
