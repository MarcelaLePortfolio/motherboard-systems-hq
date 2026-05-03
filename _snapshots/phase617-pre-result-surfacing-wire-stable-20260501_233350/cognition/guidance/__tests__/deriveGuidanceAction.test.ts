import test from "node:test";

import assert from "node:assert/strict";

import { deriveGuidanceAction }
from "../deriveGuidanceAction.ts";

import { GuidanceIntent }
from "../guidanceIntent.types.ts";


test("ESCALATE produces action",()=>{

  const action = deriveGuidanceAction(
    GuidanceIntent.ESCALATE
  );

  assert.equal(
    action.intent,
    GuidanceIntent.ESCALATE
  );

  assert.ok(
    action.recommendedSteps.length > 0
  );

});


test("MONITOR produces minimal action",()=>{

  const action = deriveGuidanceAction(
    GuidanceIntent.MONITOR
  );

  assert.equal(
    action.intent,
    GuidanceIntent.MONITOR
  );

});
