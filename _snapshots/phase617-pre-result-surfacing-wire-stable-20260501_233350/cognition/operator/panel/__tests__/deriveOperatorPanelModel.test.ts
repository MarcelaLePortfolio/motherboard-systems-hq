import test from "node:test";
import assert from "node:assert/strict";
import { deriveOperatorPanelModel } from "../deriveOperatorPanelModel.ts";

const mockCognition = {
  surface: {
    title: "Test situation",
    explanation: "System requires review",
    priority: "HIGH",
  },
  attention: {
    requiresAttention: true,
  },
  workflow: {
    requiresAcknowledgement: true,
  },
};

test("panel model produces stable deterministic output", () => {
  const a = deriveOperatorPanelModel(mockCognition as any);
  const b = deriveOperatorPanelModel(mockCognition as any);

  assert.deepEqual(a, b);
});

test("panel model does not mutate cognition input", () => {
  const frozen = Object.freeze(
    JSON.parse(JSON.stringify(mockCognition))
  );

  deriveOperatorPanelModel(frozen as any);

  assert.deepEqual(frozen, mockCognition);
});

test("panel model safely handles null", () => {
  const result = deriveOperatorPanelModel(null);

  assert.equal(result, null);
});
