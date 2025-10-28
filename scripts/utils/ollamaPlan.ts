import fs from "fs";
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

  return "🤖 No known skill found for this instruction.";
}
