import fs from "fs/promises";
import path from "path";

const TASK_PATH = path.resolve("memory/chain_task.json");

export async function readChainTaskFile(): Promise<any> {
  const raw = await fs.readFile(TASK_PATH, "utf-8");
  return JSON.parse(raw);
}
