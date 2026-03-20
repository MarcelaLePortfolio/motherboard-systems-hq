import { GuidanceIntent }
from "./guidanceIntent.types.ts";

import { SituationSeverity }
from "../situation/situation.types.ts";

export function deriveGuidanceIntent(
  severity:SituationSeverity
):GuidanceIntent{

  switch(severity){

    case SituationSeverity.CRITICAL:
      return GuidanceIntent.ESCALATE;

    case SituationSeverity.WARNING:
      return GuidanceIntent.INVESTIGATE;

    case SituationSeverity.INFO:
    default:
      return GuidanceIntent.MONITOR;

  }

}
