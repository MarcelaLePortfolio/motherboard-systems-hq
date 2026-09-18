#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"
WORKFLOW="server/matilda-chat-workflow.ts"
OLLAMA="scripts/utils/ollamaChat.ts"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"
test -n "$(git diff --name-only -- "$TEST")"

printf '\n=== PRESERVE FAILURE STATE ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=2"
echo "ATTEMPT_1_FAILURE=MISSING_TEMPORARY_IEL_TABLE"
echo "ATTEMPT_2_FAILURE=OLLAMA_INVOCATION_COUNT_ZERO"
echo "STATIC_ENDPOINT_CONTRACT=ALIGNED"
echo "ATTEMPT_3_AUTHORIZED=NO"
echo "ATTEMPT_3_EXECUTED=NO"
echo "ASSERTION_WEAKENING=PROHIBITED"

printf '\n=== OLLAMA MODULE-LOAD BINDING ===\n'
nl -ba "$OLLAMA" | sed -n '1,15p'

printf '\n=== AUTHORIZED TEST TOP-LEVEL IMPORTS ===\n'
nl -ba "$TEST" | sed -n '1,45p'

printf '\n=== FIXTURE ENVIRONMENT BINDING ORDER ===\n'
nl -ba "$TEST" | sed -n '180,220p'

printf '\n=== WORKFLOW OLLAMA DEPENDENCY ===\n'
grep -n -B8 -A8 -E \
  'ollamaChat|utils/ollamaChat' \
  "$WORKFLOW" | head -120 || true

printf '\n=== TRACE NEW ATLAS IMPORT DEPENDENCIES ===\n'
for FILE in \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts
do
  printf '\n--- %s ---\n' "$FILE"
  grep -n -E '^import|^export .* from|require\(' "$FILE" || true
done

printf '\n=== SEARCH TRANSITIVE WORKFLOW / OLLAMA REFERENCES ===\n'
git grep -n -E \
  'matilda-chat-workflow|ollamaChat|utils/ollamaChat' \
  -- \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-read-model.ts \
  server/atlas/atlas-draft-approval-observation.ts \
  server/atlas/atlas-canonical-package-observation.ts \
  2>/dev/null || true

printf '\n=== IMPORT-TIMING CLASSIFICATION ===\n'
python3 - <<'PY'
from pathlib import Path
import re

test_path = Path(
    "server/matilda-chat-workflow.explicit-target.integration.test.ts"
)
workflow_path = Path("server/matilda-chat-workflow.ts")
ollama_path = Path("scripts/utils/ollamaChat.ts")

test = test_path.read_text()
workflow = workflow_path.read_text()
ollama = ollama_path.read_text()

repo_root_marker = test.find("const repositoryRoot")
top_level = (
    test[:repo_root_marker]
    if repo_root_marker >= 0
    else test[:4000]
)

atlas_imports = re.findall(
    r'from\s+"([^"]*atlas[^"]*)"',
    top_level,
)

env_set = test.find("process.env.OLLAMA_BASE_URL")

workflow_require_candidates = [
    test.find('require(\n          "./matilda-chat-workflow"'),
    test.find('require("./matilda-chat-workflow"'),
]
workflow_require = next(
    (
        value
        for value in workflow_require_candidates
        if value >= 0
    ),
    -1,
)

module_load_binding = bool(
    re.search(
        r'const\s+OLLAMA_BASE_URL\s*=\s*'
        r'(?:\n\s*)?process\.env\.OLLAMA_BASE_URL',
        ollama,
    )
)

workflow_uses_ollama = "ollamaChat" in workflow

print(f"ENV_SET_POSITION={env_set}")
print(f"WORKFLOW_REQUIRE_POSITION={workflow_require}")
print(
    "ENV_SET_BEFORE_WORKFLOW_REQUIRE="
    + (
        "YES"
        if env_set >= 0
        and workflow_require >= 0
        and env_set < workflow_require
        else "NO"
    )
)
print(
    "OLLAMA_BASE_URL_CAPTURED_AT_MODULE_LOAD="
    + ("YES" if module_load_binding else "NO")
)
print(
    "WORKFLOW_USES_OLLAMA_CHAT="
    + ("YES" if workflow_uses_ollama else "NO")
)
print(
    "NEW_TOP_LEVEL_ATLAS_IMPORT_COUNT="
    + str(len(atlas_imports))
)
for item in atlas_imports:
    print(f"NEW_TOP_LEVEL_ATLAS_IMPORT={item}")

if (
    module_load_binding
    and env_set >= 0
    and workflow_require >= 0
    and env_set < workflow_require
    and atlas_imports
):
    print(
        "IMPORT_TIMING_HYPOTHESIS="
        "TOP_LEVEL_ATLAS_IMPORT_PRELOAD_REMAINS_PLAUSIBLE"
    )
    print(
        "NEXT_ACTION="
        "PROVE_OR_DISPROVE_PRELOAD_BEFORE_DEFINING_ATTEMPT_3"
    )
elif not module_load_binding:
    print(
        "IMPORT_TIMING_HYPOTHESIS="
        "OLLAMA_BASE_URL_NOT_CAPTURED_AT_MODULE_LOAD"
    )
    print(
        "NEXT_ACTION="
        "STOP_AND_REASSESS_WITHOUT_ATTEMPT_3"
    )
else:
    print(
        "IMPORT_TIMING_HYPOTHESIS="
        "NOT_ESTABLISHED_BY_STATIC_ORDER"
    )
    print(
        "NEXT_ACTION="
        "STOP_AND_REASSESS_WITHOUT_ATTEMPT_3"
    )
PY

printf '\n=== VERIFY AUTHORIZED TEST PRESERVED ===\n'
git diff --check -- "$TEST"
git status --short -- "$TEST"

printf '\n=== VERIFY PRODUCT BOUNDARIES ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/matilda-conversation-runtime.ts \
  db/matilda-interpretation-runtime.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

printf '\n=== VERIFY NOTHING STAGED ===\n'
test -z "$(git diff --cached --name-only)"

printf '\n=== STOP ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=2"
echo "ATTEMPT_3_AUTHORIZED=NO"
echo "ATTEMPT_3_EXECUTED=NO"
echo "PRODUCT_MUTATION=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "SCHEDULING_AUTHORITY_CHANGE=NO"
echo "ROUTING_AUTHORITY_CHANGE=NO"
echo "ORCHESTRATION_AUTHORITY_CHANGE=NO"
echo "SELF_AUTHORIZATION=NO"
echo "NEXT_ACTION=CLASSIFY_OLLAMA_IMPORT_TIMING_FROM_OUTPUT"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
