import test from "node:test";

import assert from "node:assert/strict";

import { toGoldenOperatorInteractionOutput }
from "../toGoldenOperatorInteractionOutput.ts";

import { GuidancePriority }
from "../../guidance/guidancePriority.types.ts";


test("golden operator output produces stable UI safe structure",()=>{

  const golden =
    toGoldenOperatorInteractionOutput({

      surface:{

        id:"op_1",

        priority:GuidancePriority.CRITICAL,

        title:"Escalate",

        explanation:"Risk detected",

        actionMessage:"Escalate to operator",

        recommendedSteps:[],

        prohibitedSteps:[],

        requiresHumanConfirmation:true,

        allowAutomation:false

      },

      attention:{

        level:"CRITICAL",

        badge:"Critical Attention",

        emphasis:"STRONG"

      },

      acknowledgement:{

        surfaceId:"op_1",

        acknowledged:false,

        acknowledgedAt:null,

        acknowledgedBy:null

      },

      workflow:{

        surface:{

          id:"op_1",

          priority:GuidancePriority.CRITICAL,

          title:"Escalate",

          explanation:"Risk detected",

          actionMessage:"Escalate to operator",

          recommendedSteps:[],

          prohibitedSteps:[],

          requiresHumanConfirmation:true,

          allowAutomation:false

        },

        attention:{

          level:"CRITICAL",

          badge:"Critical Attention",

          emphasis:"STRONG"

        },

        acknowledgement:{

          surfaceId:"op_1",

          acknowledged:false,

          acknowledgedAt:null,

          acknowledgedBy:null

        },

        requiresAction:true,

        readyForAutomation:false

      },

      history:[]

    });

  assert.equal(
    golden.id,
    "op_1"
  );

  assert.equal(
    golden.priority,
    "CRITICAL"
  );

  assert.equal(
    golden.requiresAction,
    true
  );

});


test("golden output reflects acknowledgement state",()=>{

  const golden =
    toGoldenOperatorInteractionOutput({

      surface:{

        id:"op_2",

        priority:GuidancePriority.LOW,

        title:"Monitor",

        explanation:"Stable",

        actionMessage:"Monitor",

        recommendedSteps:[],

        prohibitedSteps:[],

        requiresHumanConfirmation:false,

        allowAutomation:true

      },

      attention:{

        level:"LOW",

        badge:"Monitor",

        emphasis:"SUBTLE"

      },

      acknowledgement:{

        surfaceId:"op_2",

        acknowledged:true,

        acknowledgedAt:1,

        acknowledgedBy:"operator"

      },

      workflow:{

        surface:{

          id:"op_2",

          priority:GuidancePriority.LOW,

          title:"Monitor",

          explanation:"Stable",

          actionMessage:"Monitor",

          recommendedSteps:[],

          prohibitedSteps:[],

          requiresHumanConfirmation:false,

          allowAutomation:true

        },

        attention:{

          level:"LOW",

          badge:"Monitor",

          emphasis:"SUBTLE"

        },

        acknowledgement:{

          surfaceId:"op_2",

          acknowledged:true,

          acknowledgedAt:1,

          acknowledgedBy:"operator"

        },

        requiresAction:false,

        readyForAutomation:true

      },

      history:[]

    });

  assert.equal(
    golden.acknowledged,
    true
  );

  assert.equal(
    golden.readyForAutomation,
    true
  );

});

