#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

python3 - <<'PY'
from pathlib import Path

def replace(path_name: str, old: str, new: str, count: int = 1) -> None:
    path = Path(path_name)
    source = path.read_text()
    if old not in source:
        raise SystemExit(f"Expected anchor not found in {path_name}:\n{old}")
    path.write_text(source.replace(old, new, count))

# Canonical runtime fixture: Draft Revision schema must match the persisted
# Draft Revision contract now consumed by reconciliation.
replace(
    "db/matilda-canonical-package-runtime.test.ts",
    """      expected_outcome TEXT,
      unresolved_questions TEXT,""",
    """      expected_outcome TEXT,
      success_criteria TEXT,
      unresolved_questions TEXT,""",
)

# Its Draft Revision INSERT already names success_criteria, so align the
# placeholder count with the nineteen named columns.
replace(
    "db/matilda-canonical-package-runtime.test.ts",
    """) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
    """) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
)

# Supply the authored success criterion between expected_outcome and
# unresolved_questions in the Draft Revision fixture.
replace(
    "db/matilda-canonical-package-runtime.test.ts",
    """    expectedOutcome,
    null,
    JSON.stringify(["iel-canonical-test"]),""",
    """    expectedOutcome,
    "Completion is evaluated by preserving the authoritative Living Draft meaning through reconciliation.",
    null,
    JSON.stringify(["iel-canonical-test"]),""",
)

# The conflicting Canonical Package fixture now names
# approved_success_criteria; align both the column list and value list.
replace(
    "db/matilda-canonical-package-runtime.test.ts",
    """        approved_expected_outcome,
        approval_actor,""",
    """        approved_expected_outcome,
        approved_success_criteria,
        approval_actor,""",
)

replace(
    "db/matilda-canonical-package-runtime.test.ts",
    """      "Prior approved outcome.",
      "marcela",""",
    """      "Prior approved outcome.",
      "Prior approved success criteria.",
      "marcela",""",
)

# Canonical -> Mission projection fixture has ten columns but only nine
# placeholders after adding approved_success_criteria.
replace(
    "db/canonical-package-mission-projection.test.ts",
    """) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
    """) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
)

# Delegation read fixture names nineteen Canonical Package columns but
# currently supplies only eighteen values.
replace(
    "db/canonical-package-read-repository.delegation.test.ts",
    """      'Approved outcome',
      'marcela',""",
    """      'Approved outcome',
      'Approved success criteria',
      'marcela',""",
)

print("Canonical success-criteria fixture cardinalities aligned.")
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
  scripts/repair-canonical-success-criteria-fixtures.sh

git add \
  db/matilda-canonical-package-runtime.ts \
  db/canonical-package-read-repository.ts \
  db/canonical-package-mission-projection.ts \
  db/matilda-canonical-package-runtime.test.ts \
  db/canonical-package-mission-projection.test.ts \
  db/canonical-package-read-repository.delegation.test.ts \
  scripts/implement-canonical-success-criteria-lineage.sh \
  scripts/repair-canonical-success-criteria-fixtures.sh

git commit -m "Carry success criteria through canonical governance projection"
git push origin feature/support-source-references-runtime
