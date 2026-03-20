import test from "node:test";

import assert from "node:assert/strict";

import { deriveOperatorWorkflowState }
from "../deriveOperatorWorkflow.ts";

import { GuidancePriority }
from "../../guidance/guidancePriority.types.ts";


test("workflow requires action when human confirmation needed",()=>{

  const state =
    deriveOperatorWorkflowState(

      {
        id:"op_1",

        priority:GuidancePriority.CRITICAL,

        title:"Escalate",

        explanation:"Risk",

        actionMessage:"Escalate",

        recommendedSteps:["Review"],

        prohibitedSteps:[],

        requiresHumanConfirmation:true,

        allowAutomation:false
      },

      {
        level:"CRITICAL",

        badge:"Critical",

        emphasis:"STRONG"
      },

      {
        surfaceId:"op_1",

        acknowledged:false,

        acknowledgedAt:null,

        acknowledgedBy:null
      }

    );

  assert.equal(
    state.requiresAction,
    true
  );

  assert.equal(
    state.readyForAutomation,
    false
  );

});


test("workflow becomes automation ready after acknowledgement",()=>{

  const state =
    deriveOperatorWorkflowState(

      {
        id:"op_2",

        priority:GuidancePriority.MEDIUM,

        title:"Investigate",

        explanation:"Check",

        actionMessage:"Investigate",

        recommendedSteps:["Inspect"],

        prohibitedSteps:[],

        requiresHumanConfirmation:false,

        allowAutomation:true
      },

      {
        level:"MEDIUM",

        badge:"Attention",

        emphasis:"STANDARD"
      },

      {
        surfaceId:"op_2",

        acknowledged:true,

        acknowledgedAt:1,

        acknowledgedBy:"operator"
      }

    );

  assert.equal(
    state.requiresAction,
    false
  );

  assert.equal(
    state.readyForAutomation,
    true
  );

});

