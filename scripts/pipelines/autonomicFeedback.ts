import fs from "fs";
import path from "path";

const auditFile = path.resolve("db/audit.jsonl");
const insightsFile = path.resolve("db/insights.jsonl");
const reflectionsFile = path.resolve("db/reflections.jsonl");

/** Utility: safe read JSONL */
function readLines(file: string, limit = 200): any[] {
  if (!fs.existsSync(file)) return [];
  const lines = fs.readFileSync(file, "utf8").trim().split("\n");
  return lines.slice(-limit).map(l => {
    try { return JSON.parse(l); } catch { return null; }
  }).filter(Boolean);
}

/** Analyze recurring patterns and errors */
function analyzeAudit(audits: any[]) {
  const stats: Record<string, number> = {};
  const errors: Record<string, number> = {};
  for (const entry of audits) {
    const ev = entry.event;
    stats[ev] = (stats[ev] || 0) + 1;
    if (ev.includes("error") || entry.status === "error") {
      const name = entry.payload?.name ?? ev;
      errors[name] = (errors[name] || 0) + 1;
    }
  }
  return { stats, errors };
}

/** Generate human-readable feedback summary */
function generateFeedback(audits: any[], insights: any[]) {
  const { stats, errors } = analyzeAudit(audits);
  const total = audits.length;
  const errorCount = Object.keys(errors).length;
  const errorTop = Object.entries(errors)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 3)
    .map(([k, v]) => `${k} (${v})`)
    .join(", ") || "none";

  const insightThemes = insights.slice(-3).map((i: any) => i.insight).join(" | ");
  return `Cade self-audit summary:
• Total events analyzed: ${total}
• Unique error types: ${errorCount} (${errorTop})
• Recent insight themes: ${insightThemes || "no stored insights"}
Recommendation: ${errorCount > 0 ? "Review repeated errors and regenerate affected skills." : "System stable; no immediate action required."}`;
}

/** Main: run self-audit and store reflection */
export function runAutonomicAudit() {
  const audits = readLines(auditFile, 500);
  const insights = readLines(insightsFile, 200);
  const feedback = generateFeedback(audits, insights);

  const reflection = { ts: new Date().toISOString(), feedback };
  fs.mkdirSync(path.dirname(reflectionsFile), { recursive: true });
  fs.appendFileSync(reflectionsFile, JSON.stringify(reflection) + "\n", "utf8");
  return reflection;
}

/** Retrieve reflection history */
export function getReflections(limit = 20) {
  return readLines(reflectionsFile, limit);
}
