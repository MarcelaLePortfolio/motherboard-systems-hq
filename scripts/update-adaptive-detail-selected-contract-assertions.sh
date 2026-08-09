#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== UPDATE ADAPTIVE DETAIL — STALE CONTRACT ASSERTIONS ==="
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

python3 <<'PY'
from pathlib import Path

# 1. Explanation Status test:
# selectedContextSegments is now an intentional structured response artifact.
path = Path("scripts/utils/ollamaChat.explanation-status.test.ts")
text = path.read_text()

old = '''      [
        "reply",
        "explanationStatus",
        "supportSourceReferences",
        "evidence",
        "durableInterpretation",
      ],'''

new = '''      [
        "reply",
        "explanationStatus",
        "selectedContextSegments",
        "supportSourceReferences",
        "evidence",
        "durableInterpretation",
      ],'''

if old not in text:
    raise SystemExit(
        "STOP: expected Explanation Status structured-key assertion not found."
    )

path.write_text(text.replace(old, new, 1))
print("Updated Explanation Status structured response assertion.")

# 2. Support-source production test:
# support provenance now explicitly names parent project-context excerpts.
path = Path("scripts/utils/ollamaChat.support-source-production.test.ts")
text = path.read_text()

old = r'''/Set supportSourceReferences to only the supplied conversation turns or project-context excerpts that explicitly support/'''

new = r'''/Set supportSourceReferences to only the supplied conversation turns or parent project-context excerpts that explicitly support/'''

if old not in text:
    raise SystemExit(
        "STOP: expected stale support-source prompt assertion not found."
    )

path.write_text(text.replace(old, new, 1))
print("Updated support-source parent excerpt assertion.")
PY

echo
echo "=== EXISTING OLLAMA TESTS ==="
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
echo "ADAPTIVE_DETAIL_SELECTED_CONTRACT_ASSERTIONS_UPDATED"
echo "ALL_EXISTING_OLLAMA_TESTS_PASSED"
echo "READY_TO_COMMIT"
