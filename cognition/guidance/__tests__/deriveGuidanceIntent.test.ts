import test from "node:test";

import assert from "node:assert/strict";

import { deriveGuidanceIntent }
from "../deriveGuidanceIntent.ts";

import { GuidanceIntent }
from "../guidanceIntent.types.ts";

import { SituationSeverity }
from "../../situation/situation.types.ts";


test("CRITICAL → ESCALATE",()=>{

  assert.equal(

    deriveGuidanceIntent(
      SituationSeverity.CRITICAL
    ),

    GuidanceIntent.ESCALATE

  );

});


test("WARNING → INVESTIGATE",()=>{

  assert.equal(

    deriveGuidanceIntent(
      SituationSeverity.WARNING
    ),

    GuidanceIntent.INVESTIGATE

  );

});


test("INFO → MONITOR",()=>{

  assert.equal(

    deriveGuidanceIntent(
      SituationSeverity.INFO
    ),

    GuidanceIntent.MONITOR

  );

});
