import type { GuidanceAction } from "./guidanceAction.types.ts";
import type { GuidanceConstraints } from "./guidanceConstraint.types.ts";
import type { GuidanceIntent } from "./guidanceIntent.types.ts";
import type { GuidancePriority } from "./guidancePriority.types.ts";

export interface GuidanceOutput {
  intent: GuidanceIntent;
  priority: GuidancePriority;
  explanation: string;
  action: GuidanceAction;
  constraints: GuidanceConstraints;
}
