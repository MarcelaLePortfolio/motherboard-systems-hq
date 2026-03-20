import test from "node:test";

import assert from "node:assert/strict";

import { deriveGuidanceExplanation }
from "../deriveGuidanceExplanation.ts";

import { GuidanceIntent }
from "../guidanceIntent.types.ts";

import { GuidancePriority }
from "../guidancePriority.types.ts";


test("ESCALATE explanation stable",()=>{

  const text = deriveGuidanceExplanation(
    GuidanceIntent.ESCALATE,
    GuidancePriority.CRITICAL
  );

  assert.ok(
    text.includes("Critical")
  );

});


test("MONITOR explanation stable",()=>{

  const text = deriveGuidanceExplanation(
    GuidanceIntent.MONITOR,
    GuidancePriority.LOW
  );

  assert.ok(
    text.includes("Monitoring")
  );

});
