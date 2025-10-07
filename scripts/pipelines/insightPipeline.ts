import { getRecentAuditEvents } from "./opsStream";

export function generateMatildaInsights() {
  const events = getRecentAuditEvents(50);
  const recent = events.slice(-5);
  if (!recent.length) return "No recent system activity detected.";
  const topics = recent.map(e => e.event);
  return `Matilda observes ${recent.length} new system activities: ${topics.join(", ")}.`;
}
