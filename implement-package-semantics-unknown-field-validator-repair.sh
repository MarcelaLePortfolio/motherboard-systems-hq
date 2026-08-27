#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== IMPLEMENT PACKAGE SEMANTICS UNKNOWN-FIELD VALIDATOR REPAIR ==="
echo "EXPECTED_HEAD_PREFIX=e2ebc4b91"
echo "AUTHORIZATION_COMMIT=e2ebc4b918d43a7914c7679f8f197e8613f90ee0"
echo "MODE=EXECUTION_WITH_BOUNDED_AUTHORIZATION"
echo "LIVE_OLLAMA_INVOCATION=NO"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != e2ebc4b91* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

python3 - << 'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
source = path.read_text()

anchor = '''  const candidate = value as Record<string, unknown>;

  const fields = [
'''

replacement = '''  const candidate = value as Record<string, unknown>;

  const fields = [
'''

if anchor not in source:
    raise SystemExit("PACKAGE_SEMANTICS_VALIDATOR_ANCHOR_NOT_FOUND")

# First insert the unknown-key guard immediately after the existing fields array.
fields_end = '''    "unresolvedQuestions",
  ] as const;

  const validated: MatildaPackageSemanticsArtifact = {
'''

guarded_fields_end = '''    "unresolvedQuestions",
  ] as const;

  const allowedFields = new Set<string>(fields);

  for (const key of Object.keys(candidate)) {
    if (!allowedFields.has(key)) {
      throw new Error(
        `${errorPrefix} unknown package semantics field ${key}.`,
      );
    }
  }

  const validated: MatildaPackageSemanticsArtifact = {
'''

count = source.count(fields_end)
if count != 1:
    raise SystemExit(f"PACKAGE_SEMANTICS_FIELDS_END_COUNT={count}")

path.write_text(source.replace(fields_end, guarded_fields_end, 1))
PY

cat >> scripts/utils/ollamaChat.package-semantics-contract.test.ts << 'TESTS'

test(
  "Package Semantics validator fails closed on unknown fields",
  () => {
    assert.throws(
      () =>
        validateMatildaPackageSemanticsArtifact({
          ...validPackageSemantics(),
          unexpectedField: "not allowed",
        }),
      /unknown package semantics field unexpectedField/i,
    );
  },
);

test(
  "Package Semantics validator continues accepting null known fields",
  () => {
    assert.deepEqual(
      validateMatildaPackageSemanticsArtifact({
        expectedOutcome: null,
        proposedWork: null,
        proposedArtifacts: null,
        inScope: null,
        outOfScope: null,
        constraints: null,
        unresolvedQuestions: null,
      }),
      {
        expectedOutcome: null,
        proposedWork: null,
        proposedArtifacts: null,
        inScope: null,
        outOfScope: null,
        constraints: null,
        unresolvedQuestions: null,
      },
    );
  },
);
TESTS

cat > scripts/validate-package-semantics-unknown-field-iel-inheritance.test.ts << 'TS'
import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const ielSource = fs.readFileSync(
  "db/matilda-interpretation-runtime.ts",
  "utf8",
);

test(
  "IEL write inherits Package Semantics unknown-field rejection from shared validator",
  () => {
    assert.match(
      ielSource,
      /package_semantics_json:\s*[\s\S]*validateMatildaPackageSemanticsArtifact\(\s*input\.package_semantics,\s*"Matilda IEL write contains"/s,
    );
  },
);

test(
  "IEL reconstruction inherits Package Semantics unknown-field rejection from shared validator",
  () => {
    assert.match(
      ielSource,
      /function reconstructPackageSemantics\([\s\S]*validateMatildaPackageSemanticsArtifact\(\s*parsed,\s*"Matilda IEL contains"/s,
    );
  },
);
TS

echo
echo "=== VERIFY VALIDATOR ORDER ==="
VALIDATOR_LINE="$(rg -n '^export function validateMatildaPackageSemanticsArtifact' scripts/utils/ollamaChat.ts | head -1 | cut -d: -f1)"
START=$((VALIDATOR_LINE))
END=$((VALIDATOR_LINE + 95))
sed -n "${START},${END}p" scripts/utils/ollamaChat.ts

echo
echo "=== PACKAGE SEMANTICS CONTRACT TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.package-semantics-contract.test.ts

echo
echo "=== IEL INHERITANCE TESTS ==="
npx tsx --test \
  scripts/validate-package-semantics-unknown-field-iel-inheritance.test.ts \
  scripts/validate-package-semantics-iel-draft-transport.test.ts

echo
echo "=== OPTION B DIRECT FIDELITY REGRESSION ==="
npx tsx --test \
  scripts/utils/ollamaChat.package-semantics-fidelity.test.ts

echo
echo "=== OPTION B RUNTIME FIDELITY REGRESSION ==="
npx tsx --test \
  scripts/utils/ollamaChat.package-semantics-fidelity-runtime.test.ts

echo
echo "=== PACKAGE SEMANTICS OBSERVER REGRESSION ==="
npx tsx --test \
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
  scripts/utils/ollamaChat.package-semantics-contract.test.ts \
  scripts/validate-package-semantics-unknown-field-iel-inheritance.test.ts \
  implement-package-semantics-unknown-field-validator-repair.sh
git commit -m "Enforce package semantics unknown-field rejection"
git push
