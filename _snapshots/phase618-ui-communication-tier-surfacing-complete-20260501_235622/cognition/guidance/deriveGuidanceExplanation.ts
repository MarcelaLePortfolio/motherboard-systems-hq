import { GuidanceIntent } from "./guidanceIntent.types.ts";
import { GuidancePriority } from "./guidancePriority.types.ts";

export function deriveGuidanceExplanation(
  intent:GuidanceIntent,
  priority:GuidancePriority
):string{

  if(intent===GuidanceIntent.ESCALATE){
    return "Critical situation detected. Immediate operator attention recommended.";
  }

  if(intent===GuidanceIntent.ACT){
    return "System recommends corrective action to prevent degradation.";
  }

  if(intent===GuidanceIntent.INVESTIGATE){
    return "Potential issue detected. Investigation recommended.";
  }

  if(intent===GuidanceIntent.MONITOR){
    return "Situation stable. Monitoring recommended.";
  }

  return "No operator action required.";

}
