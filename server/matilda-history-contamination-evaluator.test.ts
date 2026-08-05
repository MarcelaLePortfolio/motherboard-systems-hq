import test from "node:test";
import assert from "node:assert/strict";

import type {
  MatildaEvaluatedInterpretationContext,
} from "./matilda-history-authority-evaluator";
import {
  evaluateMatildaHistoryContamination,
} from "./matilda-history-contamination-evaluator";

function createInterpretation(
  overrides:
    Partial<MatildaEvaluatedInterpretationContext> = {},
): MatildaEvaluatedInterpretationContext {
  return {
    interpretationEntryId: "iel-1",
    sourceTurnId: "turn-1",
    supersessionStatus: "unknown",
    contaminationStatus: "unassessed",
    authorityEvaluation: "unresolved",
    ...overrides,
  };
}

test(
  "marks eligible interpretations as clear",
  () => {
    const [result] =
      evaluateMatildaHistoryContamination([
        createInterpretation({
          supersessionStatus: "current",
          authorityEvaluation: "eligible",
        }),
      ]);

    assert.equal(
      result.contaminationEvaluation,
      "clear",
    );
  },
);

test(
  "detects superseded context",
  () => {
    const [result] =
      evaluateMatildaHistoryContamination([
        createInterpretation({
          supersessionStatus: "superseded",
          authorityEvaluation:
            "ineligible_superseded",
        }),
      ]);

    assert.equal(
      result.contaminationEvaluation,
      "detected_superseded_context",
    );
  },
);

test(
  "fails closed when authority is unresolved",
  () => {
    const [result] =
      evaluateMatildaHistoryContamination([
        createInterpretation(),
      ]);

    assert.equal(
      result.contaminationEvaluation,
      "unresolved",
    );
  },
);

test(
  "preserves lineage metadata",
  () => {
    const [result] =
      evaluateMatildaHistoryContamination([
        createInterpretation({
          interpretationEntryId:
            "iel-lineage",
          sourceTurnId:
            "turn-lineage",
          supersessionStatus:
            "superseded",
          authorityEvaluation:
            "ineligible_superseded",
        }),
      ]);

    assert.equal(
      result.interpretationEntryId,
      "iel-lineage",
    );

    assert.equal(
      result.sourceTurnId,
      "turn-lineage",
    );
  },
);

test(
  "does not mutate interpretation evaluations",
  () => {
    const interpretations = [
      createInterpretation({
        authorityEvaluation:
          "eligible",
        supersessionStatus:
          "current",
      }),
    ];

    const before =
      structuredClone(
        interpretations,
      );

    evaluateMatildaHistoryContamination(
      interpretations,
    );

    assert.deepEqual(
      interpretations,
      before,
    );
  },
);
