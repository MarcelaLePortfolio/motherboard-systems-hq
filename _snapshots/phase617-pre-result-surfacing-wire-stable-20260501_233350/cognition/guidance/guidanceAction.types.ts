import { GuidanceIntent }
from "./guidanceIntent.types.ts";

export interface GuidanceAction{

  intent:GuidanceIntent;

  message:string;

  recommendedSteps:string[];

}
