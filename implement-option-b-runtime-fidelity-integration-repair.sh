#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== IMPLEMENT OPTION B RUNTIME FIDELITY INTEGRATION REPAIR ==="
echo "EXPECTED_HEAD_PREFIX=da901a657"
echo "AUTHORIZATION_COMMIT=da901a6571691f9ac9d6e8b4bbc8fd0b86965cb4"
echo "MODE=EXECUTION_WITH_BOUNDED_AUTHORIZATION"
echo "LIVE_OLLAMA_INVOCATION=NO"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != da901a657* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

python3 - << 'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
source = path.read_text()

anchor = '''    const result =
      parseStructuredResponse(rawResponse);

    if (context.observeValidatedPackageSemantics) {
'''

replacement = '''    const result =
      parseStructuredResponse(rawResponse);

    enforceMatildaUserPackageSemanticsFidelity(
      validatedUserPackageSemantics,
      result.packageSemantics,
    );

    if (context.observeValidatedPackageSemantics) {
'''

count = source.count(anchor)
if count != 1:
    raise SystemExit(f"POST_PARSE_ANCHOR_COUNT={count}")

path.write_text(source.replace(anchor, replacement, 1))
PY

cat > scripts/utils/ollamaChat.package-semantics-fidelity-runtime.test.ts << 'TS'
import assert from "node:assert/strict";
import test from "node:test";

import {
  ollamaChat,
  type MatildaPackageSemanticsArtifact,
} from "./ollamaChat";

const originalFetch = globalThis.fetch;

function responseWith(
  packageSemantics: MatildaPackageSemanticsArtifact | null,
  selectedContextSegments: unknown = [],
): Response {
  return {
    ok: true,
    json: async () => ({
      response: JSON.stringify({
        reply: "Answer.",
        explanationStatus: "optional",
        selectedContextSegments,
        supportSourceReferences: [],
        evidence: null,
        investigationLifecycle: null,
        packageSemantics,
        durableInterpretation:
          "The user requested package semantics validation.",
      }),
    }),
  } as Response;
}

const exactOutcome = "Exact typed expected outcome.";

const matchingArtifact: MatildaPackageSemanticsArtifact = {
  expectedOutcome: exactOutcome,
  proposedWork: null,
  proposedArtifacts: null,
  inScope: null,
  outOfScope: null,
  constraints: null,
  unresolvedQuestions: null,
};

test("exact typed expectedOutcome passes runtime fidelity and observer", async () => {
  let fetchCount = 0;
  let observed: MatildaPackageSemanticsArtifact | null | undefined;

  globalThis.fetch = (async () => {
    fetchCount += 1;
    return responseWith(matchingArtifact);
  }) as typeof globalThis.fetch;

  try {
    const result = await ollamaChat("Question.", {
      userPackageSemantics: {
        expectedOutcome: exactOutcome,
      },
      observeValidatedPackageSemantics: (value) => {
        observed = value;
      },
    });

    assert.equal(fetchCount, 1);
    assert.equal(result.packageSemantics?.expectedOutcome, exactOutcome);
    assert.equal(observed?.expectedOutcome, exactOutcome);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("mismatch fails before package observer and selected-context rejection", async () => {
  let observerCalled = false;
  let fetchCount = 0;

  globalThis.fetch = (async () => {
    fetchCount += 1;
    return responseWith(
      {
        ...matchingArtifact,
        expectedOutcome: "Different authored outcome.",
      },
      [
        {
          relativePath: "not-supplied.ts",
          sourceStartLine: 1,
          sourceEndLine: 1,
        },
      ],
    );
  }) as typeof globalThis.fetch;

  try {
    await assert.rejects(
      () =>
        ollamaChat("Question.", {
          userPackageSemantics: {
            expectedOutcome: exactOutcome,
          },
          observeValidatedPackageSemantics: () => {
            observerCalled = true;
          },
        }),
      /explicit user package semantics fidelity for expectedOutcome/i,
    );

    assert.equal(fetchCount, 1);
    assert.equal(observerCalled, false);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("null packageSemantics fails fidelity before observer", async () => {
  let observerCalled = false;

  globalThis.fetch = (async () =>
    responseWith(null)) as typeof globalThis.fetch;

  try {
    await assert.rejects(
      () =>
        ollamaChat("Question.", {
          userPackageSemantics: {
            expectedOutcome: exactOutcome,
          },
          observeValidatedPackageSemantics: () => {
            observerCalled = true;
          },
        }),
      /explicit user package semantics fidelity: packageSemantics was null/i,
    );

    assert.equal(observerCalled, false);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("absent typed input preserves existing runtime behavior", async () => {
  globalThis.fetch = (async () =>
    responseWith(matchingArtifact)) as typeof globalThis.fetch;

  try {
    const result = await ollamaChat("Question.");
    assert.equal(result.packageSemantics?.expectedOutcome, exactOutcome);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("null typed input preserves existing runtime behavior", async () => {
  globalThis.fetch = (async () =>
    responseWith(matchingArtifact)) as typeof globalThis.fetch;

  try {
    const result = await ollamaChat("Question.", {
      userPackageSemantics: null,
    });
    assert.equal(result.packageSemantics?.expectedOutcome, exactOutcome);
  } finally {
    globalThis.fetch = originalFetch;
  }
});
TS

echo
echo "=== VERIFY RUNTIME ORDER ==="
PARSE_LINE="$(rg -n 'parseStructuredResponse\(rawResponse\)' scripts/utils/ollamaChat.ts | head -1 | cut -d: -f1)"
START=$((PARSE_LINE > 3 ? PARSE_LINE - 3 : 1))
END=$((PARSE_LINE + 22))
sed -n "${START},${END}p" scripts/utils/ollamaChat.ts

echo
echo "=== FOCUSED RUNTIME FIDELITY INTEGRATION TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.package-semantics-fidelity-runtime.test.ts

echo
echo "=== EXISTING FIDELITY TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.package-semantics-fidelity.test.ts

echo
echo "=== PACKAGE SEMANTICS AND OBSERVER REGRESSION ==="
npx tsx --test \
  scripts/utils/ollamaChat.package-semantics-contract.test.ts \
  scripts/utils/ollamaChat.package-semantics-observer.test.ts

echo
echo "=== LIFECYCLE REGRESSION ==="
npx tsx --test \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

echo
echo "=== TYPECHECK ==="
npm run check

echo
echo "=== BUILD ==="
npm run build

echo
echo "=== DIFF CHECK ==="
git diff --check

git add \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity-runtime.test.ts \
  implement-option-b-runtime-fidelity-integration-repair.sh
git commit -m "Integrate Option B runtime fidelity enforcement"
git push
