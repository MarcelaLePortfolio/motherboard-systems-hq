#!/usr/bin/env bash
set -euo pipefail

echo "=== COMMIT AND RUN BOUNDED PROMPT DIAGNOSTIC IMPLEMENTATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 52dee14a HEAD

implementation_unit="scripts/implement-bounded-validation-only-prompt-presentation-diagnostic.sh"

test -f "$implementation_unit"
test "$(git status --porcelain)" = "?? ${implementation_unit}"

echo "=== COMMIT IMPLEMENTATION UNIT CHECKPOINT ==="
git add "$implementation_unit"
git commit -m "Add bounded prompt diagnostic implementation unit"
git push origin feature/support-source-references-runtime

echo "=== VERIFY CLEAN WORKTREE ==="
test -z "$(git status --porcelain)"
echo "CLEAN_WORKTREE=CONFIRMED"

echo "=== EXECUTE AUTHORIZED IMPLEMENTATION UNIT ==="
"$implementation_unit"

echo "=== VERIFY EXPECTED IMPLEMENTATION SURFACES ==="
test -f scripts/run-bounded-prompt-presentation-diagnostic.ts
grep -q 'validationPromptPresentationVariant' scripts/utils/ollamaChat.ts
grep -q 'Validation-only project-context identity presentation:' scripts/utils/ollamaChat.ts
echo "IMPLEMENTATION_SURFACES=CONFIRMED"

git add scripts/utils/ollamaChat.ts scripts/run-bounded-prompt-presentation-diagnostic.ts

if git diff --cached --quiet; then
  echo "STOP: authorized implementation produced no staged implementation changes."
  exit 2
fi

git commit -m "Implement validation-only prompt presentation diagnostic"
git push origin feature/support-source-references-runtime

echo "DIAGNOSTIC_IMPLEMENTATION=COMPLETE"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_ACTION=RUN_BOUNDED_PROMPT_PRESENTATION_DIAGNOSTIC"
