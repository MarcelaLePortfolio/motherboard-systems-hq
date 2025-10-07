import fs from "fs";
import path from "path";
import { getRecentAuditEvents } from "./opsStream";
import { generateMatildaInsights } from "./insightPipeline";

const insightFile = path.resolve("db/insights.jsonl");

/** Append a generated insight to persistent storage */
export function storeInsight(text: string) {
  const entry = { ts: new Date().toISOString(), insight: text };
  fs.mkdirSync(path.dirname(insightFile), { recursive: true });
  fs.appendFileSync(insightFile, JSON.stringify(entry) + "\n", "utf8");
}

/** Generate and persist a new insight from recent activity */
export function captureNewInsight() {
  const summary = generateMatildaInsights();
  storeInsight(summary);
  return summary;
}

/** Retrieve the last N stored insights */
export function getStoredInsights(limit = 20) {
  if (!fs.existsSync(insightFile)) return [];
  const lines = fs.readFileSync(insightFile, "utf8").trim().split("\n").slice(-limit);
  return lines.map(l => JSON.parse(l));
}

/** Combine stored insights and current events for dashboard */
export function getInsightHistory(limit = 20) {
  const stored = getStoredInsights(limit);
  const recentEvents = getRecentAuditEvents(limit);
  return {
    count: stored.length,
    latest: stored.at(-1)?.insight ?? null,
    all: stored,
    recentEvents
  };
}
