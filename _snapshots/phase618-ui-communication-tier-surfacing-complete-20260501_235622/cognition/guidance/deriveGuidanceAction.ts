import { GuidanceIntent }
from "./guidanceIntent.types.ts";

import { GuidanceAction }
from "./guidanceAction.types.ts";

export function deriveGuidanceAction(
  intent:GuidanceIntent
):GuidanceAction{

  switch(intent){

    case GuidanceIntent.ESCALATE:

      return{

        intent,

        message:"Immediate operator attention required",

        recommendedSteps:[
          "Review situation details",
          "Check related system signals",
          "Take corrective action"
        ]

      };

    case GuidanceIntent.INVESTIGATE:

      return{

        intent,

        message:"Situation requires investigation",

        recommendedSteps:[
          "Review metrics",
          "Check recent changes",
          "Monitor for escalation"
        ]

      };

    case GuidanceIntent.MONITOR:

      return{

        intent,

        message:"Monitor situation",

        recommendedSteps:[
          "Observe system state",
          "No action required"
        ]

      };

    default:

      return{

        intent:GuidanceIntent.NONE,

        message:"No action required",

        recommendedSteps:[]
      };

  }

}
