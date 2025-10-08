import fs from "fs";
import path from "path";

/**
 * logChronicle
 * ------------
 * Lightweight Chronicle writer for real-time dashboard updates.
 */
export function logChronicle(event: string, data: any = {}) {
  const chroniclePath = path.join(process.cwd(), "logs", "system-chronicle.jsonl");
  fs.mkdirSync(path.dirname(chroniclePath), { recursive: true });

  const entry = {
    timestamp: new Date().toISOString(),
    event,
    data,
  };

  fs.appendFileSync(chroniclePath, JSON.stringify(entry) + "\n", "utf8");
  console.log(`📜 Chronicle logged: ${event}`);
}
