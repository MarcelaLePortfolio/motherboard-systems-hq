import fs from "fs";
import { ollamaChat } from "./ollamaChat.ts";

import path from "path";
import { runSkill } from "./runSkill.ts";

/**
 * 🧠 Cade's reasoning bridge — interprets instructions from Ollama
 * and decides which local skill to execute.
 */
export async function ollamaPlan(planText: string): Promise<string> {
  console.log(`<0001f9fe> 🧠 ollamaPlan interpreting: ${planText}`);

  const lower = planText.toLowerCase();

  if (lower.includes("create file") || lower.includes("write file")) {
    const match = planText.match(/file\s+(\S+)/);
    const filename = match ? match[1] : `auto_${Date.now()}`;
    return await runSkill("createFile", { filename });
  }

  if (lower.includes("read")) {
    const match = planText.match(/read\s+(\S+)/);
    const filename = match ? match[1] : "auto.txt";
    return await runSkill("readFile", { filename });
  }

  // Fallback: if no skill matched, use Ollama conversational mode
  try {
    const chatRes = await ollamaChat(message);
    if (chatRes) return chatRes;
  } catch (err) {
    console.error("⚠️ Ollama chat fallback failed:", err);
  }

  // Conversational fallback: if no skill was recognized, let Ollama handle chat
  try {
    const chatResponse = await ollamaChat(planText);
    if (chatResponse) return chatResponse;
  // Conversational fallback — if no known skill was matched
  try {
    const chatResponse = await ollamaChat(planText);
    if (chatResponse) return chatResponse;
  } catch (err) {
    console.error("⚠️ ollamaChat fallback failed:", err);
  }
  return "🤖 (chat fallback failed — no known skill)";
}
