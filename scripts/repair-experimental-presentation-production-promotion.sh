#!/usr/bin/env bash
set -euo pipefail

echo "=== REPAIR EXPERIMENTAL PRESENTATION PRODUCTION PROMOTION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 7fa5786f HEAD
test -z "$(git status --porcelain)"

target="scripts/utils/ollamaChat.ts"
test -f "$target"

python3 - <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

old = '''    const validationPromptPresentation =
      context.validationPromptPresentationVariant ===
      "explicit_parent_child_separation"
        ? ['''

new = '''    const validationPromptPresentation =
      context.validationPromptPresentationVariant === undefined ||
      context.validationPromptPresentationVariant ===
        "explicit_parent_child_separation"
        ? ['''

if old not in text:
    raise SystemExit("STOP: exact observed selector shape not found")

path.write_text(text.replace(old, new, 1))
PY

echo "=== VERIFY EXACT PROMOTION ==="
grep -n -A5 -B2 'const validationPromptPresentation' "$target"
git diff --check

echo "=== TARGETED TYPESCRIPT VALIDATION ==="
npx tsc \
  --noEmit \
  --pretty false \
  --target ES2022 \
  --module nodenext \
  --moduleResolution nodenext \
  --esModuleInterop \
  --skipLibCheck \
  "$target"

echo "TARGETED_TYPESCRIPT_VALIDATION=PASS"
echo "PROMOTION_REPAIR=COMPLETE"
echo "PRODUCTION_DEFAULT_PRESENTATION=EXPLICIT_PARENT_CHILD_SEPARATION"
echo "SEMANTIC_CONTRACT_CHANGE=NONE"
echo "SUPPORT_PROVENANCE_RULE_CHANGE=NONE"
echo "VALIDATOR_CHANGE=NONE"
echo "MODEL_CHANGE=NONE"
echo "GENERATION_POLICY_CHANGE=NONE"
echo "RETRY_OR_SECOND_MODEL_CALL=NONE"
echo "NEXT_ACTION=RUN_POST_PROMOTION_REGRESSION_VALIDATION"

git add "$target"
git commit -m "Promote validated prompt presentation to production default"
git push origin feature/support-source-references-runtime
