#!/usr/bin/env bash
set -euo pipefail

echo "=== COMMIT VALIDATED PROMPT DIAGNOSTIC SURFACES ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 124fd4bf HEAD

ollama="scripts/utils/ollamaChat.ts"
runner="scripts/run-bounded-prompt-presentation-diagnostic.ts"

test -f "$ollama"
test -f "$runner"

grep -q 'validationPromptPresentationVariant' "$ollama"
grep -q 'Validation-only project-context identity presentation:' "$ollama"
grep -q 'async function main(): Promise<void>' "$runner"
grep -q 'void main();' "$runner"

echo "=== RE-RUN TARGETED TYPESCRIPT CHECK ==="
npx tsc \
  --noEmit \
  --pretty false \
  --target ES2022 \
  --module nodenext \
  --moduleResolution nodenext \
  --esModuleInterop \
  --skipLibCheck \
  "$ollama" \
  "$runner"

echo "TARGETED_TYPESCRIPT_CHECK=PASS"
git diff --check

git add "$ollama" "$runner"

if git diff --cached --quiet; then
  echo "STOP: no diagnostic implementation changes are staged."
  exit 2
fi

git commit -m "Implement validation-only prompt presentation diagnostic"
git push origin feature/support-source-references-runtime

cat <<'MAP'
DIAGNOSTIC_IMPLEMENTATION=
COMMITTED

TARGETED_TYPESCRIPT_CHECK=
PASS

TOP_LEVEL_AWAIT_REPAIR=
VALIDATED

FULL_REPOSITORY_TYPECHECK=
STILL_BLOCKED_BY_PRE_EXISTING_ATLAS_TS2554

ATLAS_CHANGE=
NONE

PRODUCTION_PROMPT_CHANGE=
NONE

PRODUCTION_GENERATION_POLICY_CHANGE=
NONE

PRODUCTION_CHANGE=
NONE

CORRIDOR_1_STATUS=
ACTIVE

NEXT_ACTION=
RUN_BOUNDED_PROMPT_PRESENTATION_DIAGNOSTIC
MAP
