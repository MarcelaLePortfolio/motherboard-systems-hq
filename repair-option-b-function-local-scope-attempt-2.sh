#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== REPAIR OPTION B FUNCTION-LOCAL SCOPE — ATTEMPT 2 ==="
echo "EXPECTED_HEAD_PREFIX=920a08aa6"
echo "RECOVERY_POINT=DR_20260826_111719"
echo "AUTHORIZED_BY=415b595f5"
echo "ATTEMPT=2"
echo "FAILURE_1=validatedUserPackageSemantics_NOT_DEFINED_IN_ollamaChat_SCOPE"
echo "REPAIR=ADD_SINGLE_FUNCTION_LOCAL_VALIDATION_DEFINITION"
echo "CONTRACT_CHANGE=NO"
echo "PRODUCTION_SCOPE_EXPANSION=NO"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != 920a08aa6* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

python3 - <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
source = path.read_text()

anchor = '''  const trimmedMessage = message.trim();

  if (!trimmedMessage) {
    throw new Error("Ollama chat requires a non-empty message.");
  }
'''

replacement = '''  const trimmedMessage = message.trim();

  if (!trimmedMessage) {
    throw new Error("Ollama chat requires a non-empty message.");
  }

  const validatedUserPackageSemantics =
    validateMatildaUserPackageSemanticsInput(
      context.userPackageSemantics,
    );
'''

count = source.count(anchor)
if count != 1:
    raise SystemExit(f"FUNCTION_ENTRY_ANCHOR_COUNT={count}")

path.write_text(source.replace(anchor, replacement, 1))
PY

echo
echo "=== VERIFY FUNCTION-LOCAL DEFINITION ==="
sed -n '948,975p' scripts/utils/ollamaChat.ts

echo
echo "=== FOCUSED OPTION B TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.package-semantics-fidelity.test.ts

echo
echo "=== PACKAGE SEMANTICS REGRESSION ==="
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
  server/matilda-chat-workflow.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity.test.ts

git commit -m "Implement typed user package semantics fidelity"
git push
