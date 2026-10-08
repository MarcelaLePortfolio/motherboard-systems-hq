#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="a9e5aa7d2"
TARGET="scripts/utils/ollamaChat.ts"
TEST="scripts/utils/ollamaChat.bounded-reconciliation.test.ts"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test -z "$(git status --short -- "$TARGET" "$TEST")"

python3 - <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
source = path.read_text()

anchor = """    const result =
      parseStructuredResponse(rawResponse);

    if (
      context.requirePackageSemantics === true"""

replacement = """    const result =
      parseStructuredResponse(rawResponse);

    if (
      context.requirePackageSemantics === true
      && context.concreteOperationMessage
      && result.packageSemantics === null
      && !validatedUserPackageSemantics
    ) {
      const request = context.concreteOperationMessage.trim();
      const match = request.match(
        /^(remove|hide|rename|move|add|replace|show)\\s+(.+?)(?:\\s+while\\s+(.+))?\\.?$/i,
      );

      if (match) {
        const operation = match[1].toLowerCase();
        const subject = match[2].trim();
        const constraint = match[3]?.trim() ?? null;

        if (subject && !/[.!?]/.test(subject)) {
          result.packageSemantics = {
            expectedOutcome:
              `${operation} ${subject}${constraint ? ` while ${constraint}` : ""}.`,
            successCriteria: null,
            proposedWork: null,
            proposedArtifacts: null,
            inScope: null,
            outOfScope: null,
            constraints: constraint,
            unresolvedQuestions: null,
          };
        }
      }
    }

    if (
      context.requirePackageSemantics === true"""

if source.count(anchor) != 1:
    raise SystemExit("STOP: upstream insertion point changed")

path.write_text(source.replace(anchor, replacement, 1))
PY

cat > "$TEST" << 'TEST_EOF'
import assert from "node:assert/strict";
import test from "node:test";
import { ollamaChat } from "./ollamaChat";

const originalFetch = globalThis.fetch;

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

test("reconciles null semantics for a bounded concrete request", async () => {
  globalThis.fetch = (async () => responseWith(null)) as typeof fetch;

  try {
    const result = await ollamaChat(
      "Remove the Packages tab from the sidebar while preserving underlying package functionality and authority.",
      {
        requirePackageSemantics: true,
        concreteOperationMessage:
          "Remove the Packages tab from the sidebar while preserving underlying package functionality and authority.",
      },
    );

    assert.match(
      result.packageSemantics?.expectedOutcome ?? "",
      /remove the Packages tab from the sidebar/i,
    );
    assert.match(
      result.packageSemantics?.constraints ?? "",
      /preserving underlying package functionality and authority/i,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("does not replace contradictory model-authored outcome", async () => {
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
        }),
      /current-request Package Semantics fidelity/,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("does not reconcile vague requests", async () => {
  globalThis.fetch = (async () => responseWith(null)) as typeof fetch;

  try {
    await assert.rejects(
      () =>
        ollamaChat("Make the navigation better.", {
          requirePackageSemantics: true,
          concreteOperationMessage: "Make the navigation better.",
        }),
      /requires non-null Package Semantics/,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});
TEST_EOF

echo "=== TARGETED TESTS ==="
npx tsx --test \
  "$TEST" \
  scripts/utils/ollamaChat.package-semantics-contract.test.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity.test.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity-runtime.test.ts \
  scripts/utils/ollamaChat.current-request-package-semantics-fidelity.test.ts

echo "=== TYPECHECK ==="
npx tsc --noEmit

echo "=== DIFF VALIDATION ==="
git diff --check
git diff --stat -- "$TARGET"
git status --short -- "$TARGET" "$TEST"

echo "IMPLEMENTATION=TARGETED_TESTS_PASSED"
echo "LIVE_DOGFOOD=NOT_PERFORMED"
