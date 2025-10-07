import fs from "fs";
import path from "path";

const auditFile = path.resolve("db/audit.jsonl");
let lastSize = 0;

/** Return last N lines of audit log as structured objects */
export function getRecentAuditEvents(limit = 20) {
  if (!fs.existsSync(auditFile)) return [];
  const data = fs.readFileSync(auditFile, "utf8");
  const lines = data.trim().split("\n").slice(-limit);
  return lines.map(l => JSON.parse(l));
}

/** Stream new audit events since last read */
export function pollNewAuditEvents() {
  if (!fs.existsSync(auditFile)) return [];
  const stat = fs.statSync(auditFile);
  if (stat.size <= lastSize) return [];
  const data = fs.readFileSync(auditFile, "utf8").slice(lastSize);
  lastSize = stat.size;
  return data.trim().split("\n").filter(Boolean).map(l => JSON.parse(l));
}
