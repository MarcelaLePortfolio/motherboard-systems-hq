import type { GuidancePriority } from "../guidance/guidancePriority.types.ts";
import type { OperatorAttention } from "./operatorAttention.types.ts";

export function deriveOperatorAttention(
  priority: GuidancePriority
): OperatorAttention {
  switch (priority) {
    case "CRITICAL":
      return {
        level: "CRITICAL",
        badge: "Critical Attention",
        emphasis: "STRONG",
      };

    case "HIGH":
      return {
        level: "HIGH",
        badge: "High Attention",
        emphasis: "STRONG",
      };

    case "MEDIUM":
      return {
        level: "MEDIUM",
        badge: "Attention Needed",
        emphasis: "STANDARD",
      };

    case "LOW":
    default:
      return {
        level: "LOW",
        badge: "Monitor",
        emphasis: "SUBTLE",
      };
  }
}
