import test from "node:test";
import assert from "node:assert/strict";

import {
  selectMatildaInterpretationLifecycleEntries,
} from "./matilda-interpretation-lifecycle-provider";

test(
  "selects requested lifecycle entries",
  () => {
    const result =
      selectMatildaInterpretationLifecycleEntries(
        ["iel-2", "iel-1"],
        [
          {
            entry_id: "iel-1",
            supersession_status: "current",
          },
          {
            entry_id: "other",
            supersession_status: "current",
          },
          {
            entry_id: "iel-2",
            supersession_status: "superseded",
          },
        ],
      );

    assert.deepEqual(result, [
      {
        entry_id: "iel-1",
        supersession_status: "current",
      },
      {
        entry_id: "iel-2",
        supersession_status: "superseded",
      },
    ]);
  },
);

test(
  "does not mutate inputs",
  () => {
    const ids = ["iel-1"];

    const ledger = [
      {
        entry_id: "iel-1",
        supersession_status: "current",
      },
    ];

    const idsBefore =
      structuredClone(ids);

    const ledgerBefore =
      structuredClone(ledger);

    selectMatildaInterpretationLifecycleEntries(
      ids,
      ledger,
    );

    assert.deepEqual(ids, idsBefore);
    assert.deepEqual(
      ledger,
      ledgerBefore,
    );
  },
);

test(
  "returns an empty result when no entries match",
  () => {
    assert.deepEqual(
      selectMatildaInterpretationLifecycleEntries(
        ["missing"],
        [
          {
            entry_id: "other",
            supersession_status: "current",
          },
        ],
      ),
      [],
    );
  },
);
