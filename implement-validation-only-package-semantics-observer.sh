#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== IMPLEMENT VALIDATION-ONLY PACKAGE SEMANTICS OBSERVER ==="
echo "EXPECTED_HEAD_PREFIX=59c0b1aba"
echo "RECOVERY_POINT=DR_20260826_111719"
echo "AUTHORIZED_BY=806e719992d6d48b293eb623a31814691bc40ff6"
echo "SCOPE=VALIDATION_ONLY_PACKAGE_SEMANTICS_OBSERVER"
echo "PRODUCTION_BEHAVIOR_CHANGE=NO"
echo "RESULT_ACCEPTANCE_CHANGE=NO"
echo "FAIL_CLOSED_SUPPORT_VALIDATION_CHANGE=NO"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != 59c0b1aba* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

python3 - <<'PY'
from pathlib import Path

source_path = Path("scripts/utils/ollamaChat.ts")
source = source_path.read_text()

old_context = '''  observeParsedSupportSourceReferences?: (
    references: readonly MatildaSupportSourceReference[],
  ) => void;
}'''

new_context = '''  observeParsedSupportSourceReferences?: (
    references: readonly MatildaSupportSourceReference[],
  ) => void;
  observeValidatedPackageSemantics?: (
    packageSemantics: MatildaPackageSemanticsArtifact | null,
  ) => void;
}'''

if source.count(old_context) != 1:
    raise SystemExit(f"CONTEXT_TARGET_COUNT={source.count(old_context)}")

source = source.replace(old_context, new_context, 1)

old_parse = '''  if (parsed.packageSemantics !== null) {
    packageSemantics =
      validateMatildaPackageSemanticsArtifact(
        parsed.packageSemantics,
      );
  }

  const durableInterpretation ='''

new_parse = '''  if (parsed.packageSemantics !== null) {
    packageSemantics =
      validateMatildaPackageSemanticsArtifact(
        parsed.packageSemantics,
      );
  }

  if (context.observeValidatedPackageSemantics) {
    context.observeValidatedPackageSemantics(
      packageSemantics,
    );
  }

  const durableInterpretation ='''

if source.count(old_parse) != 1:
    raise SystemExit(f"PARSE_TARGET_COUNT={source.count(old_parse)}")

source = source.replace(old_parse, new_parse, 1)
source_path.write_text(source)

test_path = Path(
    "scripts/utils/ollamaChat.package-semantics-observer.test.ts"
)

test_path.write_text(r'''import assert from "node:assert/strict";
import test from "node:test";

import {
  ollamaChat,
  type MatildaPackageSemanticsArtifact,
} from "./ollamaChat";

const originalFetch = globalThis.fetch;

function responseWith(
  packageSemantics: unknown,
  supportSourceReferences: unknown = [],
): Response {
  return {
    ok: true,
    json: async () => ({
      response: JSON.stringify({
        reply: "Answer.",
        explanationStatus: "optional",
        selectedContextSegments: [],
        supportSourceReferences,
        evidence: null,
        investigationLifecycle: null,
        packageSemantics,
        durableInterpretation:
          "The user requested package semantics validation.",
      }),
    }),
  } as Response;
}

test(
  "validation-only observer receives validated package semantics before later support-provenance rejection",
  async () => {
    const observed: Array<
      MatildaPackageSemanticsArtifact | null
    > = [];

    globalThis.fetch = (async () =>
      responseWith(
        {
          expectedOutcome: "A visible checklist.",
          proposedWork: "Create the checklist.",
          proposedArtifacts: "Checklist",
          inScope: "Verify package semantics.",
          outOfScope: null,
          constraints: "Do not change authority.",
          unresolvedQuestions: null,
        },
        [
          {
            type: "conversation_turn",
            sourceTurnId: "not-supplied",
          },
        ],
      )) as typeof globalThis.fetch;

    try {
      await assert.rejects(
        () =>
          ollamaChat("Question.", {
            observeValidatedPackageSemantics:
              (packageSemantics) => {
                observed.push(packageSemantics);
              },
          }),
        /conversation support reference that was not supplied/i,
      );

      assert.equal(observed.length, 1);
      assert.equal(
        observed[0]?.expectedOutcome,
        "A visible checklist.",
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "invalid package semantics fails before validation-only observer",
  async () => {
    let observerCalled = false;

    globalThis.fetch = (async () =>
      responseWith({
        expectedOutcome: "",
        proposedWork: null,
        proposedArtifacts: null,
        inScope: null,
        outOfScope: null,
        constraints: null,
        unresolvedQuestions: null,
      })) as typeof globalThis.fetch;

    try {
      await assert.rejects(
        () =>
          ollamaChat("Question.", {
            observeValidatedPackageSemantics:
              () => {
                observerCalled = true;
              },
          }),
        /malformed package semantics field expectedOutcome/i,
      );

      assert.equal(observerCalled, false);
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "normal call without package semantics observer remains unchanged",
  async () => {
    globalThis.fetch = (async () =>
      responseWith(null)) as typeof globalThis.fetch;

    try {
      const result = await ollamaChat("Question.");

      assert.equal(result.reply, "Answer.");
      assert.equal(result.packageSemantics, null);
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
''')
PY

echo
echo "=== FOCUSED OBSERVER TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.package-semantics-observer.test.ts

echo
echo "=== PACKAGE SEMANTICS CONTRACT TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.package-semantics-contract.test.ts \
  scripts/validate-package-semantics-iel-draft-transport.test.ts

echo
echo "=== LIFECYCLE REGRESSION TESTS ==="
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
  scripts/utils/ollamaChat.package-semantics-observer.test.ts

git commit -m "Add validation-only package semantics observer"
git push
