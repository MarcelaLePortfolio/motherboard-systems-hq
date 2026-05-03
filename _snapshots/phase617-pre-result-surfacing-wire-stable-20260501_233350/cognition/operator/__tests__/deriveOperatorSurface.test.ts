import test from "node:test";

import assert from "node:assert/strict";

import { deriveOperatorSurface }
from "../deriveOperatorSurface.ts";

import { GuidancePriority }
from "../../guidance/guidancePriority.types.ts";


test("operator surface builds stable structure",()=>{

  const surface = deriveOperatorSurface({

    priority:GuidancePriority.MEDIUM,

    explanation:
      "Potential issue detected.",

    actionMessage:
      "Investigate situation",

    recommendedSteps:[
      "Review metrics"
    ],

    prohibitedSteps:[
      "Do not ignore"
    ],

    requiresHumanConfirmation:true,

    allowAutomation:false

  });

  assert.ok(
    surface.id.startsWith("op_")
  );

  assert.equal(
    surface.title,
    "Investigate situation"
  );

});


test("operator surface id is deterministic",()=>{

  const a = deriveOperatorSurface({

    priority:GuidancePriority.LOW,

    explanation:"Stable",

    actionMessage:"Monitor",

    recommendedSteps:[],

    prohibitedSteps:[],

    requiresHumanConfirmation:false,

    allowAutomation:false

  });

  const b = deriveOperatorSurface({

    priority:GuidancePriority.LOW,

    explanation:"Stable",

    actionMessage:"Monitor",

    recommendedSteps:[],

    prohibitedSteps:[],

    requiresHumanConfirmation:false,

    allowAutomation:false

  });

  assert.equal(
    a.id,
    b.id
  );

});
