import test from "node:test";
import assert from "node:assert/strict";

import type {
  MatildaInterpretationContext,
} from "./matilda-interpretation-context-runtime";
import {
  evaluateMatildaHistoryAuthority,
} from "./matilda-history-authority-evaluator";

function createInterpretation(
  overrides:
    Partial<MatildaInterpretationContext> = {},
): MatildaInterpretationContext {
  return {
    interpretationEntryId: "iel-1",
    sourceTurnId: "turn-1",
    supersessionStatus: "unknown",
    contaminationStatus: "unassessed",
    ...overrides,
  };
}

test(
  "marks current interpretations as eligible",
  () => {
    const [result] =
      evaluateMatildaHistoryAuthority([
        createInterpretation({
          supersessionStatus: "current",
        }),
      ]);

    assert.equal(
      result.authorityEvaluation,
      "eligible",
    );
  },
);

test(
  "marks superseded interpretations as ineligible",
  () => {
    const [result] =
      evaluateMatildaHistoryAuthority([
        createInterpretation({
          supersessionStatus:
            "superseded",
        }),
      ]);

    assert.equal(
      result.authorityEvaluation,
      "ineligible_superseded",
    );
  },
);

test(
  "fails closed when lifecycle state is unknown",
  () => {
    const [result] =
      evaluateMatildaHistoryAuthority([
        createInterpretation({
          supersessionStatus: "unknown",
        }),
      ]);

    assert.equal(
      result.authorityEvaluation,
      "unresolved",
    );
  },
);

test(
  "preserves interpretation metadata",
  () => {
    const [result] =
      evaluateMatildaHistoryAuthority([
        createInterpretation({
          interpretationEntryId:
            "iel-lineage",
          sourceTurnId:
            "turn-lineage",
          supersessionStatus:
            "current",
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

    assert.equal(
      result.contaminationStatus,
      "unassessed",
    );
  },
);

test(
  "does not mutate interpretation context",
  () => {
    const interpretations = [
      createInterpretation({
        supersessionStatus: "current",
      }),
    ];

    const before =
      structuredClone(
        interpretations,
      );

    evaluateMatildaHistoryAuthority(
      interpretations,
    );

    assert.deepEqual(
      interpretations,
      before,
    );
  },
);
