#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'CHECKPOINT=PRE_DELEGATION_WORKSPACE_UI_SMOKE_TEST' \
  'OBSERVED_FAILURE=MATILDA_CONVERSATIONAL_MODEL_503' \
  'MODE=DIAGNOSTIC_ONLY' \
  'IMPLEMENTATION_AUTHORIZED=NO' \
  'PRODUCTION_CHANGE=NONE' \
  'PURPOSE=LOCALIZE_503_TO_RUNTIME_MODEL_ADAPTER_OR_UPSTREAM_MODEL_SERVICE'

printf '\n=== CURRENT REPOSITORY CHECKPOINT ===\n'
git log -8 --oneline --decorate
git status --short

printf '\n=== 503 ERROR ORIGIN ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E "Matilda's conversational model is currently unavailable|503|MatildaConversationWorkflowUnavailableError" \
  routes server db client/src 2>/dev/null | head -260

printf '\n=== MATILDA WORKFLOW ERROR BOUNDARY ===\n'
sed -n '60,120p' server/matilda-chat-workflow.ts
sed -n '200,250p' routes/api-chat.ts

printf '\n=== MODEL ADAPTER / OLLAMA CALL PATH ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'Ollama|ollama|runMatildaStub|fetch\\(|11434|gemma3:4b|generate|chat' \
  server db routes 2>/dev/null | head -360

printf '\n=== LOCAL SERVER PROCESSES ===\n'
ps aux | grep -E '[n]ode|[t]sx|[v]ite|[o]llama' || true

printf '\n=== OLLAMA SERVICE HEALTH ===\n'
if curl -fsS --max-time 5 http://127.0.0.1:11434/api/tags > /tmp/matilda-ollama-tags.json; then
  echo 'OLLAMA_API_REACHABLE=YES'
  cat /tmp/matilda-ollama-tags.json
else
  echo 'OLLAMA_API_REACHABLE=NO'
fi

printf '\n=== REQUIRED MODEL PRESENCE ===\n'
if [ -s /tmp/matilda-ollama-tags.json ] && \
   grep -q 'gemma3:4b' /tmp/matilda-ollama-tags.json; then
  echo 'GEMMA3_4B_PRESENT=YES'
else
  echo 'GEMMA3_4B_PRESENT=NO_OR_UNVERIFIED'
fi

printf '\n=== OLLAMA DIRECT GENERATION SMOKE ===\n'
if curl -fsS --max-time 30 \
  http://127.0.0.1:11434/api/generate \
  -H 'Content-Type: application/json' \
  -d '{"model":"gemma3:4b","prompt":"Reply with exactly: MODEL_OK","stream":false}' \
  > /tmp/matilda-ollama-smoke.json; then
  echo 'OLLAMA_DIRECT_GENERATION=RETURNED'
  cat /tmp/matilda-ollama-smoke.json
else
  echo 'OLLAMA_DIRECT_GENERATION=FAILED'
fi

printf '\n=== RECENT LOCAL LOG CANDIDATES ===\n'
find . \
  -path './node_modules' -prune -o \
  -path './.git' -prune -o \
  -type f \
  \( -name '*.log' -o -name '*server*out*' -o -name '*server*err*' \) \
  -mmin -180 -print 2>/dev/null | head -120

printf '\n=== RECENT 503 / MODEL ERRORS FROM LOCAL LOGS ===\n'
while IFS= read -r file; do
  grep -Hni -E \
    "503|conversational model|Ollama|ollama|ECONNREFUSED|fetch failed|model.*unavailable|gemma3" \
    "$file" 2>/dev/null || true
done < <(
  find . \
    -path './node_modules' -prune -o \
    -path './.git' -prune -o \
    -type f \
    \( -name '*.log' -o -name '*server*out*' -o -name '*server*err*' \) \
    -mmin -180 -print 2>/dev/null
)

printf '\n=== DIAGNOSTIC CLASSIFICATION INPUTS ===\n'
printf '%s\n' \
  'IF_OLLAMA_UNREACHABLE=ENVIRONMENT_OR_SERVICE_AVAILABILITY' \
  'IF_MODEL_MISSING=LOCAL_MODEL_AVAILABILITY' \
  'IF_DIRECT_GENERATION_FAILS=OLLAMA_OR_MODEL_RUNTIME' \
  'IF_DIRECT_GENERATION_PASSES=INSPECT_MATILDA_ADAPTER_AND_VALIDATION_PATH' \
  'NO_FIX_AUTHORIZED=YES' \
  'NEXT_ACTION=CLASSIFY_FROM_THIS_OUTPUT'

printf '\n=== WORKTREE ===\n'
git status --short
