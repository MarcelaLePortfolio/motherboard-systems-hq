import fs from "fs";
import os from "os";
import { getRecentAuditEvents } from "./opsStream";
import { getInsightHistory } from "./persistentInsight";
import { getReflections } from "./autonomicFeedback";
import { getLessons } from "./reflectiveFeedback";
import { getCognitiveHistory } from "./cognitiveCohesion";

/** Perform a consolidated health check */
export function runSystemHealthCheck() {
  const audits = getRecentAuditEvents(10);
  const insights = getInsightHistory(10);
  const reflections = getReflections(10);
  const lessons = getLessons(10);
  const cognition = getCognitiveHistory(10);

  const uptimeSec = os.uptime();
  const uptimeHr = (uptimeSec / 3600).toFixed(1);

  const health = {
    ts: new Date().toISOString(),
    uptimeHr,
    auditCount: audits.length,
    insightCount: insights.count,
    reflectionCount: reflections.length,
    lessonCount: lessons.length,
    cognitionCount: cognition.length,
    status:
      audits.length > 0 && insights.count > 0 && reflections.length > 0
        ? "Operational"
        : "Degraded",
  };

  const summary = `System ${health.status} — ${audits.length} audits, ${insights.count} insights, ${reflections.length} reflections, ${lessons.length} lessons, ${cognition.length} cohesion entries.`;
  return { ...health, summary };
}
