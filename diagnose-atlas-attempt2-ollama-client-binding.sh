#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"
OLLAMA="scripts/utils/ollamaChat.ts"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"
test -n "$(git diff --name-only -- "$TEST")"

printf '\n=== PRESERVE FAILURE STATE ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=2"
echo "ATTEMPT_3_AUTHORIZED=NO"
echo "ATTEMPT_3_EXECUTED=NO"
echo "ASSERTION_WEAKENING=PROHIBITED"

printf '\n=== OLLAMA CHAT FUNCTION REGION ===\n'
nl -ba "$OLLAMA" | sed -n '900,1040p'

printf '\n=== OLLAMA ENVIRONMENT VARIABLES ===\n'
grep -n -E \
  'process\.env|OLLAMA|BASE_URL|HOST|PORT|URL' \
  "$OLLAMA" || true

printf '\n=== OLLAMA HTTP ENDPOINT CONSTRUCTION ===\n'
grep -n -A15 -B15 -E \
  'fetch\(|api/generate|api/chat|http://|https://|11434|127\.0\.0\.1|localhost' \
  "$OLLAMA" || true

printf '\n=== TEST FIXTURE OLLAMA ENVIRONMENT ===\n'
grep -n -A25 -B15 -E \
  'OLLAMA_BASE_URL|OLLAMA_HOST|OLLAMA_URL|process\.env|listen\(stub\)' \
  "$TEST" || true

printf '\n=== TEST STUB ACCEPTED ROUTE ===\n'
grep -n -A20 -B8 -E \
  'request\.method !== "POST"|request\.url !== "/api/generate"' \
  "$TEST" || true

printf '\n=== STATIC BINDING CLASSIFICATION ===\n'
python3 - <<'PY'
from pathlib import Path
import re

ollama = Path("scripts/utils/ollamaChat.ts").read_text()
test = Path("server/matilda-chat-workflow.explicit-target.integration.test.ts").read_text()

env_names = sorted(set(re.findall(r'process\.env\.([A-Z0-9_]+)', ollama)))
test_env_names = sorted(set(re.findall(r'process\.env\.([A-Z0-9_]+)', test)))

print("OLLAMA_CLIENT_ENV_VARS=" + ",".join(env_names))
print("TEST_ENV_VARS=" + ",".join(test_env_names))

client_generate = "/api/generate" in ollama
client_chat = "/api/chat" in ollama
stub_generate = 'request.url !== "/api/generate"' in test

print("CLIENT_REFERENCES_API_GENERATE=" + ("YES" if client_generate else "NO"))
print("CLIENT_REFERENCES_API_CHAT=" + ("YES" if client_chat else "NO"))
print("STUB_ACCEPTS_API_GENERATE=" + ("YES" if stub_generate else "NO"))

shared = sorted(set(env_names) & set(test_env_names))
print("SHARED_ENV_VARS=" + ",".join(shared))

if not shared:
    print("BINDING_CLASS=ENVIRONMENT_BINDING_DRIFT_CANDIDATE")
elif stub_generate and not client_generate:
    print("BINDING_CLASS=ENDPOINT_CONTRACT_DRIFT_CANDIDATE")
else:
    print("BINDING_CLASS=STATIC_BINDING_NOT_YET_DISPROVEN")
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
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=CLASSIFY_EXACT_OLLAMA_CLIENT_BINDING_FROM_OUTPUT"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
