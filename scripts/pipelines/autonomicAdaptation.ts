import fs from "fs";
import path from "path";
import { getSimulations } from "./introspectiveSim";

const scheduleFile = path.resolve("db/schedules.jsonl");
const adaptationFile = path.resolve("db/adaptations.jsonl");

/** Load current scheduler file (if exists) */
function readScheduleData() {
  if (!fs.existsSync(scheduleFile)) return [];
  const content = fs.readFileSync(scheduleFile, "utf8").trim();
  if (!content) return [];
  try {
    return JSON.parse(content);
  } catch {
    return [];
  }
}

/** Apply a reversible adjustment */
export function applyAdaptiveTuning() {
  const sims = getSimulations(10);
  if (!sims.length) throw new Error("No simulation data available for adaptation.");

  const latest = sims.at(-1);
  const schedules = readScheduleData();
  const logEntry: any = {
    ts: new Date().toISOString(),
    scenario: latest?.scenario ?? "unknown",
    action: null,
    note: null
  };

  // Adaptation rule: if success < 95% or risk > 5%, increase self-audit frequency
  const success = parseFloat(latest.predictedSuccess);
  const risk = parseFloat(latest.predictedRisk);

  if (success < 95 || risk > 5) {
    const audit = schedules.find((t: any) => t.id === "autonomic-feedback-6h");
    if (audit) {
      audit.intervalSec = Math.max(3600, audit.intervalSec / 2);
      logEntry.action = "increased self-audit frequency";
      logEntry.note = `Adjusted interval to ${audit.intervalSec / 3600}h due to risk ${risk}%.`;
    }
  } else if (success > 98 && risk < 3) {
    const audit = schedules.find((t: any) => t.id === "autonomic-feedback-6h");
    if (audit) {
      audit.intervalSec = Math.min(43200, audit.intervalSec * 1.5);
      logEntry.action = "relaxed self-audit frequency";
      logEntry.note = `Extended interval to ${audit.intervalSec / 3600}h (stable conditions).`;
    }
  } else {
    logEntry.action = "no change";
    logEntry.note = "Parameters within normal range.";
  }

  fs.writeFileSync(scheduleFile, JSON.stringify(schedules, null, 2), "utf8");
  fs.appendFileSync(adaptationFile, JSON.stringify(logEntry) + "\n", "utf8");
  return logEntry;
}

/** Retrieve adaptation history */
export function getAdaptations(limit = 20) {
  if (!fs.existsSync(adaptationFile)) return [];
  const lines = fs.readFileSync(adaptationFile, "utf8").trim().split("\n").slice(-limit);
  return lines.map(l => JSON.parse(l));
}
