#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

python3 <<'PY'
from pathlib import Path
import re

path = Path("scripts/utils/ollamaChat.explanation-status.test.ts")
text = path.read_text()

pattern = re.compile(
    r'(\[\s*'
    r'"reply",\s*'
    r'"explanationStatus",\s*)'
    r'("supportSourceReferences",\s*'
    r'"evidence",\s*'
    r'"durableInterpretation",\s*'
    r'\])'
)

updated, count = pattern.subn(
    r'\1"selectedContextSegments",\n        \2',
    text,
    count=1,
)

if count != 1:
    raise SystemExit(
        "STOP: could not uniquely locate the stale structured-response key assertion."
    )

path.write_text(updated)
print("Updated structured-response key assertion.")

path = Path("scripts/utils/ollamaChat.support-source-production.test.ts")
text = path.read_text()

old = (
    r"/Set supportSourceReferences to only the supplied conversation turns "
    r"or project-context excerpts that explicitly support/"
)

new = (
    r"/Set supportSourceReferences to only the supplied conversation turns "
    r"or parent project-context excerpts that explicitly support/"
)

if old not in text:
    raise SystemExit(
        "STOP: stale support-source prompt assertion was not found."
    )

path.write_text(text.replace(old, new, 1))
print("Updated support-source prompt assertion.")
PY

echo
echo "=== TARGETED TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.explanation-status.test.ts \
  scripts/utils/ollamaChat.support-source-production.test.ts

echo
echo "=== FULL OLLAMA REGRESSION TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.test.ts \
  scripts/utils/ollamaChat.summary-composition.test.ts \
  scripts/utils/ollamaChat.reasoning-composition.test.ts \
  scripts/utils/ollamaChat.boundary-composition.test.ts \
  scripts/utils/ollamaChat.explanation-status.test.ts \
  scripts/utils/ollamaChat.explanation-request.test.ts \
  scripts/utils/ollamaChat.evidence-sufficiency-gate.test.ts \
  scripts/utils/ollamaChat.explicit-evidence-request-context.test.ts \
  scripts/utils/ollamaChat.structured-evidence-object.test.ts \
  scripts/utils/ollamaChat.support-source-references.test.ts \
  scripts/utils/ollamaChat.support-source-production.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_SELECTED_CONTRACT_VALIDATED"

git add \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat*.test.ts \
  scripts/implement-adaptive-detail-prompt-selected-contract.sh \
  scripts/validate-adaptive-detail-prompt-selected-contract.sh \
  scripts/migrate-ollama-selected-context-test-fixtures.sh \
  scripts/update-adaptive-detail-selected-contract-assertions.sh \
  scripts/repair-adaptive-detail-selected-contract-assertions.sh && \
git commit -m "Add Adaptive Detail selected context contract" && \
git push
