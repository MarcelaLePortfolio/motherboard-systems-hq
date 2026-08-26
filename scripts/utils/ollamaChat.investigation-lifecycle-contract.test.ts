import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";

import {
  validateMatildaInvestigationLifecycleContinuity,
  type MatildaInvestigationLifecycleArtifact,
  type MatildaInvestigationLifecycleEvent,
} from "./ollamaChat";

const source = fs.readFileSync(
  "scripts/utils/ollamaChat.ts",
  "utf8",
);

function lifecycle(
  lifecycleEvent: MatildaInvestigationLifecycleEvent,
  investigationIdentity = "investigation-alpha",
): MatildaInvestigationLifecycleArtifact {
  return {
    investigationIdentity,
    governingQuestion:
      "What repository-supported boundary governs this investigation?",
    lifecycleEvent,
    lifecycleDetermination:
      lifecycleEvent === "advanced" ||
      lifecycleEvent === "resolved"
        ? "A material investigation determination was established."
        : null,
  };
}

test(
  "Investigation Lifecycle is a required nullable structured artifact",
  () => {
    assert.match(source, /"investigationLifecycle",/);
    assert.match(
      source,
      /investigationLifecycle:\s*\{\s*anyOf:/s,
    );
    assert.match(source, /type:\s*"null"/);
    assert.match(
      source,
      /structured response without investigation lifecycle/,
    );
  },
);

test(
  "Investigation Lifecycle uses the bounded event vocabulary",
  () => {
    for (const event of [
      "entered",
      "continued",
      "advanced",
      "resolved",
      "superseded",
      "abandoned",
    ]) {
      assert.match(source, new RegExp(`"${event}"`));
    }
  },
);

test(
  "Investigation Lifecycle validates semantic identity and governing question",
  () => {
    assert.match(source, /without investigation identity/);
    assert.match(source, /without governing question/);
  },
);

test(
  "advanced and resolved require a lifecycle determination",
  () => {
    assert.match(source, /lifecycleEvent === "advanced"/);
    assert.match(source, /lifecycleEvent === "resolved"/);
    assert.match(source, /without required determination/);
  },
);

test(
  "ordinary conversation is instructed to return null lifecycle",
  () => {
    assert.match(
      source,
      /Set investigationLifecycle to null when the current response does not semantically enter, continue, advance, resolve, supersede, or abandon an investigation\./,
    );
  },
);

test(
  "lifecycle identity is not derived from conversation storage identity",
  () => {
    assert.match(
      source,
      /Do not use conversation identifiers or interpretation-entry identifiers as investigationIdentity merely because those identifiers exist\./,
    );
  },
);

test("null prior and null current are accepted", () => {
  assert.doesNotThrow(() =>
    validateMatildaInvestigationLifecycleContinuity(
      null,
      null,
    ),
  );
});

test("null prior and entered current are accepted", () => {
  assert.doesNotThrow(() =>
    validateMatildaInvestigationLifecycleContinuity(
      null,
      lifecycle("entered"),
    ),
  );
});

test("prior lifecycle and null current are accepted", () => {
  assert.doesNotThrow(() =>
    validateMatildaInvestigationLifecycleContinuity(
      lifecycle("continued"),
      null,
    ),
  );
});

test("continued preserves prior investigation identity", () => {
  assert.doesNotThrow(() =>
    validateMatildaInvestigationLifecycleContinuity(
      lifecycle("continued", "investigation-alpha"),
      lifecycle("continued", "investigation-alpha"),
    ),
  );

  assert.throws(
    () =>
      validateMatildaInvestigationLifecycleContinuity(
        lifecycle("continued", "investigation-alpha"),
        lifecycle("continued", "investigation-beta"),
      ),
    /continued investigation lifecycle with investigation identity that does not match prior lifecycle context/,
  );
});

test("advanced preserves prior investigation identity", () => {
  assert.doesNotThrow(() =>
    validateMatildaInvestigationLifecycleContinuity(
      lifecycle("continued", "investigation-alpha"),
      lifecycle("advanced", "investigation-alpha"),
    ),
  );

  assert.throws(
    () =>
      validateMatildaInvestigationLifecycleContinuity(
        lifecycle("continued", "investigation-alpha"),
        lifecycle("advanced", "investigation-beta"),
      ),
    /advanced investigation lifecycle with investigation identity that does not match prior lifecycle context/,
  );
});

for (const event of [
  "entered",
  "resolved",
  "superseded",
  "abandoned",
] as const) {
  test(`${event} does not inherit an unauthorized identity transition rule`, () => {
    assert.doesNotThrow(() =>
      validateMatildaInvestigationLifecycleContinuity(
        lifecycle("continued", "investigation-alpha"),
        lifecycle(event, "investigation-beta"),
      ),
    );
  });
}

test(
  "cross-turn validator is invoked after structured response parsing",
  () => {
    assert.match(
      source,
      /const result =\s*parseStructuredResponse\(rawResponse\);[\s\S]*?validateMatildaInvestigationLifecycleContinuity\(\s*context\.priorInvestigationLifecycle \?\? null,\s*result\.investigationLifecycle,\s*\);/,
    );
  },
);
