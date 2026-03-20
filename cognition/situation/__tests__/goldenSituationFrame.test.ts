import test from "node:test";
import assert from "node:assert/strict";

import { ConfidenceLevel } from "../../guidance/guidance.types.ts";

import { toGoldenSituationFrame }
from "../goldenSituationFrame.ts";

import {
SituationCategory,
SituationSeverity
}
from "../situation.types.ts";


test("golden frame strips behavior fields",()=>{

  const golden = toGoldenSituationFrame({

    classification:{
      category:SituationCategory.INFO,
      severity:SituationSeverity.INFO,
      confidence:ConfidenceLevel.LOW
    },

    title:"Test",

    summary:"Summary",

    attentionLevel:"LOW",

    orderHint:100,

    context:{
      metric:"latency"
    }

  });

  assert.equal(golden.title,"Test");

  assert.equal(golden.summary,"Summary");

  assert.equal(golden.attentionLevel,"LOW");

  assert.deepEqual(
    golden.facts,
    {metric:"latency"}
  );

});


test("golden frame converts values to strings",()=>{

  const golden = toGoldenSituationFrame({

    classification:{
      category:SituationCategory.INFO,
      severity:SituationSeverity.INFO,
      confidence:ConfidenceLevel.LOW
    },

    title:"Test",

    summary:"Summary",

    attentionLevel:"LOW",

    context:{
      value:42,
      active:true
    }

  });

  assert.deepEqual(
    golden.facts,
    {
      value:"42",
      active:"true"
    }
  );

});
