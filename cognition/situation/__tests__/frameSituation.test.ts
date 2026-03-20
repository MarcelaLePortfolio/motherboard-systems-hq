import test from "node:test";
import assert from "node:assert/strict";

import { ConfidenceLevel } from "../../scripts/_local/phase92_fix_guidance_imports.sh";
import { frameSituation } from "../frameSituation.ts";
import { SituationCategory, SituationSeverity } from "../situation.types.ts";

test("frameSituation produces deterministic CRITICAL HEALTH frame", () => {
  const frame = frameSituation({
    category: SituationCategory.HEALTH,
    severity: SituationSeverity.CRITICAL,
    confidence: ConfidenceLevel.HIGH,
  });

  assert.equal(frame.title, "Critical System Health Risk");
  assert.equal(frame.attentionLevel, "HIGH");
  assert.equal(frame.orderHint, 100);
  assert.match(frame.summary, /critical/i);
  assert.equal(frame.context, undefined);
});

test("frameSituation produces deterministic WARNING PERFORMANCE frame", () => {
  const frame = frameSituation({
    category: SituationCategory.PERFORMANCE,
    severity: SituationSeverity.WARNING,
    confidence: ConfidenceLevel.MEDIUM,
  });

  assert.equal(frame.title, "Performance Warning");
  assert.equal(frame.attentionLevel, "MEDIUM");
  assert.equal(frame.orderHint, 200);
  assert.equal(frame.context, undefined);
});

test("frameSituation produces deterministic INFO frame", () => {
  const frame = frameSituation({
    category: SituationCategory.INFO,
    severity: SituationSeverity.INFO,
    confidence: ConfidenceLevel.LOW,
  });

  assert.equal(frame.title, "Situation Informational");
  assert.equal(frame.attentionLevel, "LOW");
  assert.equal(frame.orderHint, 300);
  assert.equal(frame.context, undefined);
});

test("frameSituation preserves flexible context when provided", () => {
  const context = {
    component: "workerA",
    metric: "queue_latency",
    value: 842,
    trend: "increasing",
  };

  const frame = frameSituation(
    {
      category: SituationCategory.PERFORMANCE,
      severity: SituationSeverity.WARNING,
      confidence: ConfidenceLevel.MEDIUM,
    },
    context
  );

  assert.deepEqual(frame.context, context);
  assert.equal(frame.title, "Performance Warning");
  assert.equal(frame.attentionLevel, "MEDIUM");
  assert.equal(frame.orderHint, 200);
});
