#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
BASELINE="9f86ce053"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 '@{u}')" = "$BASELINE"

python3 - <<'PY'
from pathlib import Path

path = Path("db/matilda-canonical-package-runtime.test.ts")
source = path.read_text()

old = """) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"""
new = """) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"""

if source.count(old) != 1:
    raise SystemExit(
        "Expected exactly one remaining 18-placeholder Canonical fixture INSERT; "
        f"found {source.count(old)}."
    )

source = source.replace(old, new, 1)

old = """          draft_revision_id,
          approved_expected_outcome
        FROM matilda_canonical_packages"""

new = """          draft_revision_id,
          approved_expected_outcome,
          approved_success_criteria
        FROM matilda_canonical_packages"""

if old not in source:
    raise SystemExit(
        "Expected rollback-verification Canonical SELECT anchor not found."
    )

source = source.replace(old, new, 1)

old = """        draft_revision_id: string;
        approved_expected_outcome: string;
      }>;"""

new = """        draft_revision_id: string;
        approved_expected_outcome: string;
        approved_success_criteria: string;
      }>;"""

if old not in source:
    raise SystemExit(
        "Expected rollback-verification Canonical row type anchor not found."
    )

source = source.replace(old, new, 1)

path.write_text(source)

print(
    "Final projection-conflict fixture repaired: "
    "19 Canonical columns now have 19 placeholders and rollback verification "
    "reads approved_success_criteria."
)
PY

npx tsc --noEmit

node --import tsx --test \
  db/matilda-reconciled-intent-runtime.test.ts \
  db/matilda-canonical-package-runtime.test.ts \
  db/canonical-package-mission-projection.test.ts \
  db/canonical-package-read-repository.delegation.test.ts

git diff --check -- \
  db/matilda-canonical-package-runtime.ts \
  db/canonical-package-read-repository.ts \
  db/canonical-package-mission-projection.ts \
  db/matilda-canonical-package-runtime.test.ts \
  db/canonical-package-mission-projection.test.ts \
  db/canonical-package-read-repository.delegation.test.ts \
  scripts/implement-canonical-success-criteria-lineage.sh \
  scripts/repair-canonical-success-criteria-fixtures.sh \
  scripts/repair-final-canonical-projection-conflict-fixture.sh

git add \
  db/matilda-canonical-package-runtime.ts \
  db/canonical-package-read-repository.ts \
  db/canonical-package-mission-projection.ts \
  db/matilda-canonical-package-runtime.test.ts \
  db/canonical-package-mission-projection.test.ts \
  db/canonical-package-read-repository.delegation.test.ts \
  scripts/implement-canonical-success-criteria-lineage.sh \
  scripts/repair-canonical-success-criteria-fixtures.sh \
  scripts/repair-final-canonical-projection-conflict-fixture.sh

git commit -m "Carry success criteria through canonical governance projection"
git push origin "$BRANCH"
