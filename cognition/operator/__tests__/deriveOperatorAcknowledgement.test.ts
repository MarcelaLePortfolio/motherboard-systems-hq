import test from "node:test";

import assert from "node:assert/strict";

import { createOperatorAcknowledgement }
from "../deriveOperatorAcknowledgement.ts";

import { acknowledgeOperatorSurface }
from "../deriveOperatorAcknowledgement.ts";

import { GuidancePriority }
from "../../guidance/guidancePriority.types.ts";


test("ack record initializes unacknowledged",()=>{

  const ack = createOperatorAcknowledgement({

    id:"op_1",

    priority:GuidancePriority.LOW,

    title:"Monitor",

    explanation:"Stable",

    actionMessage:"Monitor",

    recommendedSteps:[],

    prohibitedSteps:[],

    requiresHumanConfirmation:false,

    allowAutomation:false

  });

  assert.equal(
    ack.acknowledged,
    false
  );

});


test("acknowledgement becomes stable once set",()=>{

  const initial = createOperatorAcknowledgement({

    id:"op_1",

    priority:GuidancePriority.LOW,

    title:"Monitor",

    explanation:"Stable",

    actionMessage:"Monitor",

    recommendedSteps:[],

    prohibitedSteps:[],

    requiresHumanConfirmation:false,

    allowAutomation:false

  });

  const updated =
    acknowledgeOperatorSurface(
      initial,
      "operator",
      123
    );

  assert.equal(
    updated.acknowledged,
    true
  );

  assert.equal(
    updated.acknowledgedBy,
    "operator"
  );

});
