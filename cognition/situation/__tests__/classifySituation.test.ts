import test from "node:test";
import assert from "node:assert/strict";

import { ConfidenceLevel } from "../../scripts/_local/phase92_fix_guidance_imports.sh";
import { classifySituation } from "../classifySituation.ts";
import { SituationCategory, SituationSeverity } from "../situation.types.ts";

test("classifySituation returns deterministic defaults when no input is provided", () => {
  assert.deepEqual(classifySituation(), {
    category: SituationCategory.INFO,
    severity: SituationSeverity.INFO,
    confidence: ConfidenceLevel.LOW,
    metadata: undefined,
    signals: undefined,
  });
});

test("classifySituation preserves explicit classification input", () => {
  assert.deepEqual(
    classifySituation({
      category: SituationCategory.RISK,
      severity: SituationSeverity.CRITICAL,
      confidence: ConfidenceLevel.HIGH,
      metadata: { source: "unit-test" },
      signals: ["signal-a"],
    }),
    {
      category: SituationCategory.RISK,
      severity: SituationSeverity.CRITICAL,
      confidence: ConfidenceLevel.HIGH,
      metadata: { source: "unit-test" },
      signals: ["signal-a"],
    }
  );
});
