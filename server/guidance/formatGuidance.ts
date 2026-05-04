/**
 * Phase 672.1 — Guidance Formatting Layer
 * Pure presentation transformation only.
 */

export function formatGuidanceForDisplay(item: any) {
  const severityLabel =
    item.type === "critical"
      ? "requires attention"
      : item.type === "warning"
      ? "monitor"
      : "observe";

  const messageMap: Record<string, string> = {
    "Execution subsystem is not verified.": "Execution integrity requires validation.",
    "Retried tasks are present in recent task history.": "Elevated retry activity detected.",
  };

  return {
    type: item.type,
    severity: item.severity,
    subsystem: item.subsystem,
    message: messageMap[item.message] || item.message,
    tone: severityLabel,
    suggested_action: item.suggested_action,
    generated_at: item.generated_at,
  };
}
