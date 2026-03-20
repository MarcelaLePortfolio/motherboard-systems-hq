import test from "node:test";
import assert from "node:assert/strict";

import { deriveOperatorAttention } from "../deriveOperatorAttention.ts";
import { GuidancePriority } from "../../guidance/guidancePriority.types.ts";

test("CRITICAL priority maps to strong critical attention", () => {
  const attention = deriveOperatorAttention(GuidancePriority.CRITICAL);

  assert.deepEqual(attention, {
    level: "CRITICAL",
    badge: "Critical Attention",
    emphasis: "STRONG",
  });
});

test("HIGH priority maps to strong high attention", () => {
  const attention = deriveOperatorAttention(GuidancePriority.HIGH);

  assert.deepEqual(attention, {
    level: "HIGH",
    badge: "High Attention",
    emphasis: "STRONG",
  });
});

test("MEDIUM priority maps to standard attention", () => {
  const attention = deriveOperatorAttention(GuidancePriority.MEDIUM);

  assert.deepEqual(attention, {
    level: "MEDIUM",
    badge: "Attention Needed",
    emphasis: "STANDARD",
  });
});

test("LOW priority maps to subtle monitoring attention", () => {
  const attention = deriveOperatorAttention(GuidancePriority.LOW);

  assert.deepEqual(attention, {
    level: "LOW",
    badge: "Monitor",
    emphasis: "SUBTLE",
  });
});
