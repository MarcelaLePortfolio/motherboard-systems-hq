import assert from "node:assert/strict";
import test from "node:test";

import {
  __testOnlyReconstructPackageSemantics,
} from "./matilda-interpretation-runtime";

test("legacy IEL Package Semantics without successCriteria reconstructs it as null", () => {
  const legacy = JSON.stringify({
    expectedOutcome:
      "The frontend displays information without the 'Packages' tab, maintaining access to all package runtime data and functionality.",
    proposedWork:
      "Remove the 'Packages' tab from the frontend sidebar.",
    proposedArtifacts:
      "Frontend code changes reflecting the tab removal.",
    inScope:
      "Changes to the frontend UI specifically related to the 'Packages' tab.",
    outOfScope:
      "Changes to the backend or package runtime components responsible for package management.",
    constraints:
      "All underlying package runtime functionality and authority must remain unchanged.",
    unresolvedQuestions: null,
  });

  const reconstructed =
    __testOnlyReconstructPackageSemantics(legacy);

  assert.equal(reconstructed?.successCriteria, null);
  assert.equal(
    reconstructed?.expectedOutcome,
    "The frontend displays information without the 'Packages' tab, maintaining access to all package runtime data and functionality.",
  );
});

test("explicit current successCriteria remains unchanged during reconstruction", () => {
  const current = JSON.stringify({
    expectedOutcome: "Remove the Packages tab.",
    successCriteria: "The Packages tab is absent from the sidebar.",
    proposedWork: null,
    proposedArtifacts: null,
    inScope: null,
    outOfScope: null,
    constraints: null,
    unresolvedQuestions: null,
  });

  const reconstructed =
    __testOnlyReconstructPackageSemantics(current);

  assert.equal(
    reconstructed?.successCriteria,
    "The Packages tab is absent from the sidebar.",
  );
});
