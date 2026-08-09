#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== REPAIR ADAPTIVE DETAIL — STALE PARENT SUPPORT PRESENTATION ASSERTION ==="

if [[ "$(git rev-parse --short HEAD)" != "fc8483cb" ]]; then
  echo "STOP: HEAD no longer matches presentation-collision checkpoint fc8483cb."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^ M scripts/utils/ollamaChat\.ts$|^\?\? scripts/utils/ollamaChat\.child-identity-presentation\.test\.ts$|^\?\? scripts/separate-adaptive-detail-child-identity-presentation\.sh$|^\?\? scripts/repair-adaptive-detail-parent-support-presentation-assertion\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

python3 <<'PY'
from pathlib import Path
import re

path = Path(
    "scripts/utils/ollamaChat.parent-support-identity-prompt.test.ts"
)
text = path.read_text()

pattern = re.compile(
    r'''assert\.match\(
\s*source,
\s*/Segment source:/,
\s*\);'''
)

replacement = '''assert.match(
      source,
      /Segment candidate:/,
    );

    assert.match(
      source,
      /relativePath =/,
    );

    assert.match(
      source,
      /sourceStartLine =/,
    );

    assert.match(
      source,
      /sourceEndLine =/,
    );

    assert.doesNotMatch(
      source,
      /Segment source:/,
    );'''

updated, count = pattern.subn(replacement, text, count=1)

if count != 1:
    print("=== CURRENT PARENT SUPPORT IDENTITY TEST ===")
    print(text)
    raise SystemExit(
        f"STOP: expected exactly one multiline stale Segment source assertion; found {count}."
    )

path.write_text(updated)

print(
    "Updated stale parent-support assertion to named-field child identity presentation."
)
PY

echo
echo "=== TARGETED PRESENTATION TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.parent-support-identity-prompt.test.ts \
  scripts/utils/ollamaChat.child-identity-presentation.test.ts

echo
echo "=== FULL OLLAMA REGRESSION SUITE ==="
npx tsx --test scripts/utils/ollamaChat*.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY OLD RUNTIME PRESENTATION ABSENT ==="
if grep -n 'Segment source:' scripts/utils/ollamaChat.ts; then
  echo "STOP: old colon-style child identity presentation remains in runtime."
  exit 2
fi

echo "OLD_CHILD_SOURCE_PRESENTATION_ABSENT"

echo
echo "=== VERIFY NEW RUNTIME PRESENTATION ==="
grep -n \
  -E 'Segment candidate:|relativePath =|sourceStartLine =|sourceEndLine =' \
  scripts/utils/ollamaChat.ts

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_CHILD_IDENTITY_PRESENTATION_VALIDATED"
echo "STALE_ASSERTION_REPAIRED=true"
echo "SUPPORT_VALIDATION_UNCHANGED=true"
echo "SELECTED_CONTEXT_SEGMENTS_RUNTIME_IDENTITY_UNCHANGED=true"
echo "MODEL_INVOCATION_COUNT_UNCHANGED=true"
echo "NEXT_UNIT=RERUN_ADAPTIVE_DETAIL_MIXED_CONTENT_BEHAVIOR_LIVE"

git add \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat.parent-support-identity-prompt.test.ts \
  scripts/utils/ollamaChat.child-identity-presentation.test.ts \
  scripts/separate-adaptive-detail-child-identity-presentation.sh \
  scripts/repair-adaptive-detail-parent-support-presentation-assertion.sh

git commit -m "Separate Adaptive Detail child identity presentation"
git push
