import test from "node:test";
import assert from "node:assert/strict";

import { ConfidenceLevel } from "../../guidance/guidance.types.ts";
import { normalizeSituationFrame } from "../normalizeSituationFrame.ts";
import { SituationCategory, SituationSeverity } from "../situation.types.ts";

test("normalizeSituationFrame stabilizes empty title", () => {

  const frame = normalizeSituationFrame({

    classification:{
      category:SituationCategory.INFO,
      severity:SituationSeverity.INFO,
      confidence:ConfidenceLevel.LOW
    },

    title:"",
    summary:"ok",
    attentionLevel:"LOW"
  });

  assert.equal(frame.title,"Situation");
});


test("normalizeSituationFrame stabilizes bad orderHint", () => {

  const frame = normalizeSituationFrame({

    classification:{
      category:SituationCategory.INFO,
      severity:SituationSeverity.INFO,
      confidence:ConfidenceLevel.LOW
    },

    title:"A",
    summary:"B",
    attentionLevel:"LOW",
    orderHint:NaN as unknown as number
  });

  assert.equal(frame.orderHint,undefined);
});


test("normalizeSituationFrame removes invalid context", () => {

  const frame = normalizeSituationFrame({

    classification:{
      category:SituationCategory.INFO,
      severity:SituationSeverity.INFO,
      confidence:ConfidenceLevel.LOW
    },

    title:"A",
    summary:"B",
    attentionLevel:"LOW",
    context:"bad" as unknown as object
  });

  assert.equal(frame.context,undefined);
});
