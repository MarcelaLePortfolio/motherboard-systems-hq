import test from "node:test";
import assert from "node:assert/strict";

import { deriveGuidancePriority } from "../deriveGuidancePriority.ts";
import { GuidanceIntent } from "../guidanceIntent.types.ts";
import { GuidancePriority } from "../guidancePriority.types.ts";

test("ESCALATE -> CRITICAL", () => {
  assert.equal(
    deriveGuidancePriority(GuidanceIntent.ESCALATE),
    GuidancePriority.CRITICAL
  );
});

test("ACT -> HIGH", () => {
  assert.equal(
    deriveGuidancePriority(GuidanceIntent.ACT),
    GuidancePriority.HIGH
  );
});

test("INVESTIGATE -> MEDIUM", () => {
  assert.equal(
    deriveGuidancePriority(GuidanceIntent.INVESTIGATE),
    GuidancePriority.MEDIUM
  );
});

test("MONITOR -> LOW", () => {
  assert.equal(
    deriveGuidancePriority(GuidanceIntent.MONITOR),
    GuidancePriority.LOW
  );
});

test("NONE -> LOW", () => {
  assert.equal(
    deriveGuidancePriority(GuidanceIntent.NONE),
    GuidancePriority.LOW
  );
});
