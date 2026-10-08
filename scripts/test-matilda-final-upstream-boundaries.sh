#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="f9e6099ca"
TEST="scripts/utils/ollamaChat.bounded-reconciliation.final-boundaries.test.ts"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test -z "$(git status --short -- "$TEST" scripts/utils/ollamaChat.ts)"
test ! -e "$TEST"

cat > "$TEST" << 'TEST_EOF'
import assert from "node:assert/strict";
import test from "node:test";
import { ollamaChat } from "./ollamaChat";

const originalFetch = globalThis.fetch;

const request =
  "Remove the Packages tab from the sidebar while preserving underlying package functionality and authority.";

function responseWith(packageSemantics: unknown): Response {
  return {
    ok: true,
    json: async () => ({
      response: JSON.stringify({
        reply: "Acknowledged.",
        explanationStatus: "optional",
        selectedContextCandidatePositions: [],
        supportSourceReferences: [],
        evidence: null,
        investigationLifecycle: null,
        packageSemantics,
        durableInterpretation: "The user requested a sidebar change.",
      }),
    }),
  } as Response;
}

test("reconciled semantics remain non-authoritative", async () => {
  globalThis.fetch = (async () => responseWith(null)) as typeof fetch;

  try {
    const result = await ollamaChat(request, {
      requirePackageSemantics: true,
      concreteOperationMessage: request,
      executionAuthorized: false,
    });

    assert.equal(result.packageSemantics?.proposedWork, null);
    assert.equal(result.packageSemantics?.proposedArtifacts, null);
    assert.equal(result.packageSemantics?.inScope, null);
    assert.equal(result.packageSemantics?.outOfScope, null);
    assert.match(
      result.packageSemantics?.constraints ?? "",
      /preserving underlying package functionality and authority/i,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("malformed non-outcome semantics fail before observer", async () => {
  let observerCalled = false;

  globalThis.fetch = (async () =>
    responseWith({
      expectedOutcome: null,
      successCriteria: null,
      proposedWork: 42,
      proposedArtifacts: null,
      inScope: null,
      outOfScope: null,
      constraints: null,
      unresolvedQuestions: null,
    })) as typeof fetch;

  try {
    await assert.rejects(
      () =>
        ollamaChat(request, {
          requirePackageSemantics: true,
          concreteOperationMessage: request,
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

test("valid authored non-outcome fields remain unchanged", async () => {
  const authored = {
    expectedOutcome: "Remove the Packages tab from the sidebar.",
    successCriteria: "Package functionality remains available.",
    proposedWork: null,
    proposedArtifacts: null,
    inScope: "Sidebar navigation only.",
    outOfScope: "Underlying package execution.",
    constraints: "Preserve existing authority.",
    unresolvedQuestions: null,
  };

  globalThis.fetch = (async () =>
    responseWith(authored)) as typeof fetch;

  try {
    const result = await ollamaChat(request, {
      requirePackageSemantics: true,
      concreteOperationMessage: request,
    });

    assert.deepEqual(result.packageSemantics, authored);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("null semantics without required context remain null", async () => {
  globalThis.fetch = (async () => responseWith(null)) as typeof fetch;

  try {
    const result = await ollamaChat("What is the current status?");
    assert.equal(result.packageSemantics, null);
  } finally {
    globalThis.fetch = originalFetch;
  }
});
TEST_EOF

echo "=== FINAL UPSTREAM REGRESSION TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.bounded-reconciliation.test.ts \
  "$TEST" \
  scripts/utils/ollamaChat.package-semantics-contract.test.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity.test.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity-runtime.test.ts \
  scripts/utils/ollamaChat.current-request-package-semantics-fidelity.test.ts

echo "=== TYPECHECK ==="
npx tsc --noEmit

echo "=== DIFF CHECK ==="
git diff --check

echo "UPSTREAM_BOUNDARY_TESTS=PASS"
echo "PRODUCTION_SOURCE=UNCHANGED"
echo "CONTRADICTORY_NON_OUTCOME_SEMANTIC_FIDELITY=NOT_YET_PROVEN"
echo "WORKFLOW_PERSISTENCE=NOT_YET_VERIFIED"
echo "LIVE_DOGFOOD=NOT_PERFORMED"
echo "CORRIDOR=OPEN"
