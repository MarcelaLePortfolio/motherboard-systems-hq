import test from "node:test";

import assert from "node:assert/strict";

import { deriveOperatorCognition }
from "../deriveOperatorCognition.ts";

import { GuidancePriority }
from "../../guidance/guidancePriority.types.ts";

test("operator cognition wires situation to operator output",()=>{

  const result =
    deriveOperatorCognition(

      {
        id:"sit_1",

        classification:"HEALTH",

        severity:"CRITICAL",

        title:"Health risk",

        summary:"Health degradation detected",

        orderHint:1,

        context:{}

      },

      {
        intent:"ESCALATE",

        priority:GuidancePriority.CRITICAL,

        explanation:"Risk detected",

        actionMessage:"Escalate",

        recommendedSteps:[],

        prohibitedSteps:[],

        requiresHumanConfirmation:true,

        allowAutomation:false

      }

    );

  assert.equal(
    result.surface.priority,
    GuidancePriority.CRITICAL
  );

  assert.equal(
    result.workflow.requiresAction,
    true
  );

});


test("operator cognition produces deterministic stable structure",()=>{

  const result =
    deriveOperatorCognition(

      {
        id:"sit_2",

        classification:"INFO",

        severity:"INFO",

        title:"Stable",

        summary:"System stable",

        orderHint:1,

        context:{}

      },

      {
        intent:"MONITOR",

        priority:GuidancePriority.LOW,

        explanation:"Stable",

        actionMessage:"Monitor",

        recommendedSteps:[],

        prohibitedSteps:[],

        requiresHumanConfirmation:false,

        allowAutomation:false

      }

    );

  assert.equal(
    result.surface.title,
    "Stable"
  );

  assert.equal(
    result.workflow.readyForAutomation,
    false
  );

});

