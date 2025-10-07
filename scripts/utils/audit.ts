import fs from "fs";
import path from "path";

const auditPath = path.resolve("db/audit.jsonl");

export function audit(event: string, data: any) {
  try {
    const line = JSON.stringify({ ts: Date.now(), event, data }) + "\n";
    fs.appendFileSync(auditPath, line, "utf8");
  } catch {}
}
