#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== MIGRATE OLLAMA TEST FIXTURES — SELECTED CONTEXT SEGMENTS ==="
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

if [[ "$(git rev-parse --short HEAD)" != "51185ee8" ]]; then
  echo "STOP: expected uncommitted implementation on HEAD 51185ee8."
  exit 2
fi

python3 <<'PY'
from pathlib import Path
import re

paths = sorted(Path("scripts/utils").glob("ollamaChat*.test.ts"))

changed_files = []
changed_fixtures = 0

for path in paths:
    text = path.read_text()
    original = text

    pattern = re.compile(
        r'(?P<indent>^[ \t]*)supportSourceReferences\s*:',
        re.MULTILINE,
    )

    def add_selected(match):
        global changed_fixtures
        indent = match.group("indent")
        changed_fixtures += 1
        return (
            f"{indent}selectedContextSegments: [],\n"
            f"{indent}supportSourceReferences:"
        )

    text = pattern.sub(add_selected, text)

    if text != original:
        path.write_text(text)
        changed_files.append(str(path))

print(f"Updated fixtures: {changed_fixtures}")
print(f"Changed files: {len(changed_files)}")
for path in changed_files:
    print(path)

if changed_fixtures == 0:
    raise SystemExit(
        "STOP: no existing supportSourceReferences fixtures were found to migrate."
    )
PY

echo
echo "=== VERIFY FIXTURE MIGRATION ==="
missing="$(
  grep -L 'selectedContextSegments' \
    scripts/utils/ollamaChat*.test.ts \
    || true
)"
printf '%s\n' "$missing"

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
echo "OLLAMA_SELECTED_CONTEXT_TEST_FIXTURES_MIGRATED"
echo "PRODUCTION_CODE_NOT_CHANGED_BY_THIS_UNIT"
echo "NEXT_ACTION=COMMIT_ONLY_AFTER_FULL_TEST_PASS"
