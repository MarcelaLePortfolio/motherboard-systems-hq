import assert from "node:assert/strict";
import test from "node:test";

import {
  retrieveMatildaProjectContext,
} from "./matilda-project-context-retrieval";

const projectRootPath = process.cwd();

test(
  "Packages removal-gate retrieval selects the directly relevant checkpoint",
  () => {
    const result = retrieveMatildaProjectContext({
      projectId: "hq",
      projectRootPath,
      message:
        "i want to remove the Packages tab. what still needs to be verified before that removal gate is satisfied?",
    });

    assert.equal(result.available, true);
    assert.equal(result.searched, true);

    const paths = result.excerpts.map(
      (excerpt) => excerpt.relativePath,
    );

    assert.ok(
      paths.includes(
        "docs/checkpoints/APPROVALS_EXECUTIVE_INBOX_PRESENTATION_COMPLETE.md",
      ),
      [
        "Expected the Packages removal-gate checkpoint to be selected.",
        `Selected paths: ${paths.join(", ")}`,
      ].join("\n"),
    );
  },
);


test(
  "repository evidence question retrieves the Packages navigation control",
  () => {
    const result = retrieveMatildaProjectContext({
      projectId: "hq",
      projectRootPath,
      message:
        "What repository evidence identifies the component responsible for rendering the Packages navigation tab?",
    });

    assert.equal(result.available, true);
    assert.equal(result.searched, true);
    assert.equal(result.warning, null);
    assert.ok(result.excerpts.length <= 6);

    const navigation = result.projectContextSegmentCandidates.filter(
      (candidate) =>
        candidate.parentRelativePath ===
        "client/src/shell/NavigationRegion.tsx",
    );

    assert.equal(navigation.length, 1);
    assert.equal(navigation[0].sourceStartLine, 71);
    assert.equal(navigation[0].sourceEndLine, 83);
    assert.match(navigation[0].text, /onSelectWorkspace\("packages"\)/);
    assert.match(navigation[0].text, />\s*Packages\s*<\/button>/);
  },
);
