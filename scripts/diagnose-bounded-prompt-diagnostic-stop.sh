#!/usr/bin/env bash
set -euo pipefail

echo "=== DIAGNOSE BOUNDED PROMPT DIAGNOSTIC STOP ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"

echo "=== WORKTREE ==="
git status --short

echo "=== REQUIRED FILES ==="
for file in \
  scripts/implement-bounded-validation-only-prompt-presentation-diagnostic.sh \
  scripts/utils/ollamaChat.ts \
  scripts/run-bounded-prompt-presentation-diagnostic.ts
do
  if [[ -f "$file" ]]; then
    echo "PRESENT=$file"
  else
    echo "ABSENT=$file"
  fi
done

echo "=== IMPLEMENTATION MARKERS ==="
grep -n 'validationPromptPresentationVariant' scripts/utils/ollamaChat.ts || true
grep -n 'Validation-only project-context identity presentation:' scripts/utils/ollamaChat.ts || true

echo "=== AUTHORIZATION ANCESTRY ==="
if git merge-base --is-ancestor 3c18d4df HEAD; then
  echo "AUTHORIZATION_ANCESTOR=YES"
else
  echo "AUTHORIZATION_ANCESTOR=NO"
fi

echo "NEXT_ACTION=CLASSIFY_EXACT_STOP_CAUSE_FROM_THIS_OUTPUT"
