#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="26772c927"
TARGET="scripts/utils/ollamaChat.bounded-reconciliation.test.ts"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test -z "$(git status --short -- "$TARGET" scripts/utils/ollamaChat.ts)"

BACKUP="$(mktemp)"
cp "$TARGET" "$BACKUP"

restore_on_failure() {
  cp "$BACKUP" "$TARGET"
  rm -f "$BACKUP"
}
trap restore_on_failure ERR

cat >> "$TARGET" << 'TEST_EOF'

test("preserves valid model-authored semantics unchanged", async () => {
  const authored = {
    expectedOutcome: "Remove the Packages tab from the sidebar.",
    successCriteria: "Packages remains functional.",
    proposedWork: null,
    proposedArtifacts: null,
    inScope: null,
    outOfScope: null,
    constraints: "Preserve underlying package functionality.",
    unresolvedQuestions: null,
  };

  globalThis.fetch = (async () => responseWith(authored)) as typeof fetch;

  try {
    const result = await ollamaChat(
      "Remove the Packages tab from the sidebar.",
      {
        requirePackageSemantics: true,
        concreteOperationMessage:
          "Remove the Packages tab from the sidebar.",
      },
    );

    assert.deepEqual(result.packageSemantics, authored);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("missing outcome in non-null artifact fails closed", async () => {
  globalThis.fetch = (async () =>
    responseWith({
      expectedOutcome: null,
      successCriteria: null,
      proposedWork: null,
      proposedArtifacts: null,
      inScope: null,
      outOfScope: null,
      constraints: null,
      unresolvedQuestions: null,
    })) as typeof fetch;

  try {
    await assert.rejects(
      () =>
        ollamaChat("Remove the Packages tab from the sidebar.", {
          requirePackageSemantics: true,
          concreteOperationMessage:
            "Remove the Packages tab from the sidebar.",
        }),
      /requires non-null Package Semantics with a non-empty expectedOutcome/,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("explicit typed semantics are not replaced by reconciliation", async () => {
  let observerCalled = false;
  globalThis.fetch = (async () => responseWith(null)) as typeof fetch;

  try {
    await assert.rejects(
      () =>
        ollamaChat("Remove the Packages tab from the sidebar.", {
          requirePackageSemantics: true,
          concreteOperationMessage:
            "Remove the Packages tab from the sidebar.",
          userPackageSemantics: {
            expectedOutcome: "Exact user-authored outcome.",
          },
          observeValidatedPackageSemantics: () => {
            observerCalled = true;
          },
        }),
    );

    assert.equal(observerCalled, false);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("successful reconciliation reaches validated observer", async () => {
  let observed: unknown;
  const request =
    "Remove the Packages tab from the sidebar while preserving underlying package functionality and authority.";

  globalThis.fetch = (async () => responseWith(null)) as typeof fetch;

  try {
    const result = await ollamaChat(request, {
      requirePackageSemantics: true,
      concreteOperationMessage: request,
      observeValidatedPackageSemantics: (value) => {
        observed = value;
      },
    });

    assert.deepEqual(observed, result.packageSemantics);
    assert.equal(result.packageSemantics?.proposedWork, null);
    assert.equal(result.packageSemantics?.proposedArtifacts, null);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("contradictory authored outcome never reaches observer", async () => {
  let observerCalled = false;

  globalThis.fetch = (async () =>
    responseWith({
      expectedOutcome: "Add a dashboard widget.",
      successCriteria: null,
      proposedWork: null,
      proposedArtifacts: null,
      inScope: null,
      outOfScope: null,
      constraints: null,
      unresolvedQuestions: null,
    })) as typeof fetch;

  try {
    await assert.rejects(
      () =>
        ollamaChat("Remove the Packages tab from the sidebar.", {
          requirePackageSemantics: true,
          concreteOperationMessage:
            "Remove the Packages tab from the sidebar.",
          observeValidatedPackageSemantics: () => {
            observerCalled = true;
          },
        }),
    );

    assert.equal(observerCalled, false);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("ambiguous concrete request does not generate semantics", async () => {
  globalThis.fetch = (async () => responseWith(null)) as typeof fetch;

  try {
    await assert.rejects(
      () =>
        ollamaChat("Remove.", {
          requirePackageSemantics: true,
          concreteOperationMessage: "Remove.",
        }),
      /requires non-null Package Semantics/,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("malformed model semantics remain rejected", async () => {
  globalThis.fetch = (async () =>
    responseWith({
      expectedOutcome: 42,
      successCriteria: null,
      proposedWork: null,
      proposedArtifacts: null,
      inScope: null,
      outOfScope: null,
      constraints: null,
      unresolvedQuestions: null,
    })) as typeof fetch;

  try {
    await assert.rejects(
      () =>
        ollamaChat("Remove the Packages tab from the sidebar.", {
          requirePackageSemantics: true,
          concreteOperationMessage:
            "Remove the Packages tab from the sidebar.",
        }),
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});
TEST_EOF

echo "=== EXPANDED TARGETED REGRESSION TESTS ==="

npx tsx --test \
  scripts/utils/ollamaChat.bounded-reconciliation.test.ts \
  scripts/utils/ollamaChat.package-semantics-contract.test.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity.test.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity-runtime.test.ts \
  scripts/utils/ollamaChat.current-request-package-semantics-fidelity.test.ts

echo "=== TYPECHECK ==="
npx tsc --noEmit

echo "=== DIFF CHECK ==="
git diff --check

echo "=== SUCCESS ==="
echo "UPSTREAM_REGRESSION_TESTS=PASS"
echo "PRODUCTION_SOURCE=UNCHANGED"
echo "WORKFLOW_PERSISTENCE_TESTS=STILL_REQUIRED"
echo "CONTRADICTORY_NON_OUTCOME_FIELD_TEST=STILL_REQUIRED"
echo "LIVE_DOGFOOD=NOT_PERFORMED"
echo "CORRIDOR=OPEN"

trap - ERR
rm -f "$BACKUP"
