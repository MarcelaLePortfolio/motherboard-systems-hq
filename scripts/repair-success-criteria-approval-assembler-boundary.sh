#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
BASELINE="46f7516b5"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 '@{u}')" = "$BASELINE"

python3 - <<'PY'
from pathlib import Path

path = Path("db/approval-request-model-assembler.ts")
source = path.read_text()

old = """    expected_outcome: source.expected_outcome,
    success_criteria: draft.success_criteria,
    unresolved_questions: source.unresolved_questions,"""

new = """    expected_outcome: source.expected_outcome,
    success_criteria: revision.success_criteria,
    unresolved_questions: source.unresolved_questions,"""

if old not in source:
    raise SystemExit(
        "Expected failed-attempt approval assembler projection was not found."
    )

source = source.replace(old, new, 1)
path.write_text(source)

print("Approval assembler now projects success criteria from the immutable Draft Revision.")
PY

npx tsc --noEmit

node --import tsx --test \
  db/matilda-reconciled-intent-runtime.test.ts \
  db/matilda-canonical-package-runtime.test.ts

git diff --check -- \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-reconciled-intent-runtime.ts \
  db/approval-request-model-assembler.ts \
  scripts/implement-success-criteria-draft-revision-summary.sh \
  scripts/repair-success-criteria-approval-assembler-boundary.sh

git add \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-reconciled-intent-runtime.ts \
  db/approval-request-model-assembler.ts \
  scripts/implement-success-criteria-draft-revision-summary.sh \
  scripts/repair-success-criteria-approval-assembler-boundary.sh

git commit -m "Carry success criteria through reconciled summary"
git push origin "$BRANCH"
