import fs from "fs";
import path from "path";

const chronicleFile = path.resolve("db/system_chronicle.jsonl");

/** Append a human-readable chronicle entry */
export function recordChronicle(event: string, detail: any = {}) {
  const entry = {
    ts: new Date().toISOString(),
    event,
    detail,
  };
  fs.mkdirSync(path.dirname(chronicleFile), { recursive: true });
  fs.appendFileSync(chronicleFile, JSON.stringify(entry) + "\n", "utf8");
  return entry;
}

/** Retrieve the last N chronicle entries */
export function getChronicle(limit = 50) {
  if (!fs.existsSync(chronicleFile)) return [];
  const lines = fs.readFileSync(chronicleFile, "utf8").trim().split("\n").slice(-limit);
  return lines.map(l => JSON.parse(l));
}
