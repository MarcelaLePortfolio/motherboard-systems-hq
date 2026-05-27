// <0001fb02> Phase 9.9d — ollamaPlan Hybrid (Reasoning + Chat Fallback)
import fs from "fs";
import path from "path";
import { runSkill } from "./runSkill.ts";
import { execSync } from "child_process";

/**
 * 🧠 Hybrid Ollama Planner — uses local reasoning for known skills,
 * falls back to chat completion if no actionable instruction found.
 */
export async function ollamaPlan(planText: string): Promise<string> {
  console.log(`<0001fb02> 🧠 ollamaPlan interpreting: ${planText}`);
  const lower = planText.toLowerCase();

  // --- Skill routing ---
  if (lower.includes("create file") || lower.includes("write file")) {
    const match = planText.match(/file\s+(\S+)/);
    const filename = match ? match[1] : `auto_${Date.now()}`;
    return await runSkill("createFile", { filename });
  }
  if (lower.includes("read")) {
    return await runSkill("readFile", {});
  }

  // --- Fallback: Chat mode via Ollama ---
  try {
    const result = execSync(
      `ollama run gemma:2b "You are Matilda, an intelligent local AI assistant. Respond conversationally to: ${planText}"`,
      { encoding: "utf8" }
    );
    return result.trim();
  } catch (err) {
    console.error("⚠️ Ollama chat fallback failed:", err);
    return "🧩 (fallback) unable to generate response";
  }
}
