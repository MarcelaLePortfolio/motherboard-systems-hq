#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="85d104cf6"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== TEST RUNNER CONTRACT INSPECTION ==="
echo "HEAD=$EXPECTED_HEAD"
echo "FUNCTIONAL_MUTATION=NO"
echo "DOGFOOD_RETRY=NO"

echo
echo "=== CURRENT STATUS ==="
git status --short

echo
echo "=== PACKAGE TEST SCRIPTS ==="
node -e '
const p=require("./package.json");
console.log(JSON.stringify(p.scripts,null,2));
'

echo
echo "=== TYPESCRIPT EXECUTION DEPENDENCIES ==="
node -e '
const p=require("./package.json");
const all={...(p.dependencies||{}),...(p.devDependencies||{})};
for (const name of ["tsx","ts-node","typescript"]) {
  console.log(`${name}=${all[name] ?? "ABSENT"}`);
}
'

echo
echo "=== IMPORT FORMS IN AFFECTED TESTS ==="
for f in \
  scripts/utils/ollamaChat.conditional-conversation-support-prompt.test.ts \
  scripts/utils/ollamaChat.package-semantics-contract.test.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity.test.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity-runtime.test.ts \
  scripts/utils/ollamaChat.expected-outcome-diagnostic-observability.test.ts \
  scripts/utils/ollamaChat.package-semantics-generation-grounding.test.ts
do
  echo "--- $f ---"
  sed -n '1,45p' "$f" 2>/dev/null || true
done

echo
echo "=== HISTORICAL INVOCATION EVIDENCE ==="
git log --all -S'ollamaChat.conditional-conversation-support-prompt.test.ts' \
  --oneline --decorate -- scripts package.json 2>/dev/null | head -30 || true

git grep -n \
  -e 'conditional-conversation-support-prompt' \
  -e 'package-semantics-contract' \
  -e 'package-semantics-fidelity-runtime' \
  -e 'node --test.*ollamaChat' \
  -e 'tsx.*ollamaChat' \
  -- ':!scripts/inspect-ollamachat-test-runner-contract.sh' \
  2>/dev/null | head -160 || true

echo
echo "=== CLASSIFICATION BOUNDARY ==="
echo "GROUNDING_TEST_PREVIOUS_RESULT=PASS"
echo "TYPECHECK_PREVIOUS_RESULT=PASS"
echo "BUILD_PREVIOUS_RESULT=PASS"
echo "RUNTIME_IMPORT_TEST_FAILURE_CLASS=RUNNER_OR_MODULE_RESOLUTION_UNRESOLVED"
echo "EMPTY_HISTORY_SCHEMA_BOUNDING_TEST=ABANDONED_STALE_APPROACH"
echo "ATTEMPT_3_NOT_STARTED=YES"

echo
echo "=== SAFETY BOUNDARY ==="
echo "NO_FUNCTIONAL_SOURCE_CHANGED=YES"
echo "NO_TEST_CHANGED=YES"
echo "NO_VALIDATOR_CHANGED=YES"
echo "NO_SCHEMA_CHANGED=YES"
echo "NO_AUTHORITY_MODEL_CHANGED=YES"
echo "NO_DOGFOOD_RETRY_PERFORMED=YES"
echo "UNRELATED_WORKTREE_PRESERVED=YES"
