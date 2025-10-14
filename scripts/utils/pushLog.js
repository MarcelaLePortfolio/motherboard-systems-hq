import fs from "fs";
import path from "path";

/**
 * pushLog(entry)
 * Appends a new log line to a small local JSON cache for `/logs/recent`.
 */
export async function pushLog(entry) {
  const logFile = path.join(process.cwd(), "memory", "logs.json");
  fs.mkdirSync(path.dirname(logFile), { recursive: true });

  let logs = [];
  if (fs.existsSync(logFile)) {
    try {
      logs = JSON.parse(fs.readFileSync(logFile, "utf8"));
    } catch {
      logs = [];
    }
  }

  const record = {
    id: Date.now(),
    level: entry.level || "info",
    message: entry.message || "(no message)",
    timestamp: new Date().toISOString()
  };

  logs.unshift(record);
  if (logs.length > 50) logs = logs.slice(0, 50); // keep recent only
  fs.writeFileSync(logFile, JSON.stringify(logs, null, 2), "utf8");

  return record;
}
