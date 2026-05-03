import type { GuidancePriority } from "../guidance/guidancePriority.types.ts";

export interface OperatorSurface {

  id:string;

  priority:GuidancePriority;

  title:string;

  explanation:string;

  actionMessage:string;

  recommendedSteps:string[];

  prohibitedSteps:string[];

  requiresHumanConfirmation:boolean;

  allowAutomation:boolean;

}
