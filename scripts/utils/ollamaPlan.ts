import fs from "fs";
import path from "path";
import { runSkill } from "./runSkill.ts";
import { ollamaChat } from "./ollamaChat.ts";

/**
 * 🧠 Cade's reasoning bridge — interprets instructions from Ollama
 * and decides which local skill to execute.
 */
export async function ollamaPlan(planText: string): Promise<string> {
  console.log(`<0001f9fe> 🧠 ollamaPlan interpreting: ${planText}`);

  const lower = planText.toLowerCase();

  if (lower.includes("create file") || lower.includes("write file")) {
    const match = planText.match(/file\s+(\S+)/);
    return await runSkill("createFile", { path: match?.[1] || "unknown.txt" });
  }

  // Conversational fallback — if no known skill was matched
  try {
    const chatResponse = await ollamaChat(planText);
    if (chatResponse) return chatResponse;
  } catch (err) {
    console.error("⚠️ ollamaChat fallback failed:", err);
  }

  console.log("<0001fa9f> 💬 ollamaChat fallback result reached — chatResponse may have been empty");

  return "🤖 No known skill found for this instruction.";
}
