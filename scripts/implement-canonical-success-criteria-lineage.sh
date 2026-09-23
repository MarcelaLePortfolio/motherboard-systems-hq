#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
BASELINE="f3c4926e4"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 '@{u}')" = "$BASELINE"

python3 - <<'PY'
from pathlib import Path

def replace(path_name: str, old: str, new: str, count: int = 1):
    path = Path(path_name)
    source = path.read_text()
    if source.count(old) < count:
        raise SystemExit(f"Expected anchor not found enough times in {path_name}:\n{old}")
    path.write_text(source.replace(old, new, count))

canonical = "db/matilda-canonical-package-runtime.ts"

replace(
    canonical,
    """      approved_constraints TEXT,
      approved_expected_outcome TEXT,
      approval_actor TEXT NOT NULL,""",
    """      approved_constraints TEXT,
      approved_expected_outcome TEXT,
      approved_success_criteria TEXT,
      approval_actor TEXT NOT NULL,""",
)

path = Path(canonical)
source = path.read_text()

old = """  if (
    hasPackageVersion
    && hasDraftRevisionId
    && !packageIdPrimaryKeyOnly
  ) {
    return;
  }"""

new = """  if (
    hasPackageVersion
    && hasDraftRevisionId
    && !packageIdPrimaryKeyOnly
  ) {
    if (!columns.some((column) => column.name === "approved_success_criteria")) {
      sqlite.exec(`
        ALTER TABLE matilda_canonical_packages
        ADD COLUMN approved_success_criteria TEXT
      `);
    }

    return;
  }"""

if old not in source:
    raise SystemExit("Modern Canonical Package migration return anchor not found.")

source = source.replace(old, new, 1)
path.write_text(source)

replace(
    canonical,
    """  if (
    typeof summary.expected_outcome !== "string"
    || summary.expected_outcome.trim().length === 0
  ) {
    throw new Error(
      "Canonical Package approval requires a non-empty expected_outcome.",
    );
  }

  const latest = sqlite""",
    """  if (
    typeof summary.expected_outcome !== "string"
    || summary.expected_outcome.trim().length === 0
  ) {
    throw new Error(
      "Canonical Package approval requires a non-empty expected_outcome.",
    );
  }

  if (
    typeof summary.success_criteria !== "string"
    || summary.success_criteria.trim().length === 0
  ) {
    throw new Error(
      "Canonical Package approval requires a non-empty success_criteria.",
    );
  }

  const latest = sqlite""",
)

replace(
    canonical,
    """            approved_constraints,
            approved_expected_outcome,
            approval_actor,""",
    """            approved_constraints,
            approved_expected_outcome,
            approved_success_criteria,
            approval_actor,""",
)

replace(
    canonical,
    """          ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
    """          ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
)

replace(
    canonical,
    """          summary.constraints,
          summary.expected_outcome,
          approval_actor,""",
    """          summary.constraints,
          summary.expected_outcome,
          summary.success_criteria,
          approval_actor,""",
)

replace(
    canonical,
    """    approved_constraints: summary.constraints,
    approved_expected_outcome: summary.expected_outcome,
    approval_actor,""",
    """    approved_constraints: summary.constraints,
    approved_expected_outcome: summary.expected_outcome,
    approved_success_criteria: summary.success_criteria,
    approval_actor,""",
)

read_repo = "db/canonical-package-read-repository.ts"

replace(
    read_repo,
    """  approved_constraints: string | null;
  approved_expected_outcome: string | null;
  approval_actor: string;""",
    """  approved_constraints: string | null;
  approved_expected_outcome: string | null;
  approved_success_criteria: string | null;
  approval_actor: string;""",
)

replace(
    read_repo,
    """      approved_constraints,
      approved_expected_outcome,
      approval_actor,""",
    """      approved_constraints,
      approved_expected_outcome,
      approved_success_criteria,
      approval_actor,""",
)

projection = "db/canonical-package-mission-projection.ts"

replace(
    projection,
    """  approved_expected_outcome: string | null;
  approved_scope: string | null;""",
    """  approved_expected_outcome: string | null;
  approved_success_criteria: string | null;
  approved_scope: string | null;""",
)

replace(
    projection,
    """    && existing.constraints === source.approved_constraints
    && existing.success_criteria === null
    && existing.context === null""",
    """    && existing.constraints === source.approved_constraints
    && existing.success_criteria === source.approved_success_criteria
    && existing.context === null""",
)

replace(
    projection,
    """        approved_expected_outcome,
        approved_scope,""",
    """        approved_expected_outcome,
        approved_success_criteria,
        approved_scope,""",
)

replace(
    projection,
    """  const scope = requireText(source.approved_scope, "approved_scope");""",
    """  const success_criteria = requireText(
    source.approved_success_criteria,
    "approved_success_criteria",
  );

  const scope = requireText(source.approved_scope, "approved_scope");""",
)

replace(
    projection,
    """        @constraints,
        NULL,
        NULL,""",
    """        @constraints,
        @success_criteria,
        NULL,""",
)

replace(
    projection,
    """      scope,
      constraints,
      created_at,""",
    """      scope,
      constraints,
      success_criteria,
      created_at,""",
)

tests = "db/matilda-canonical-package-runtime.test.ts"
path = Path(tests)
source = path.read_text()

source = source.replace(
    "      approved_expected_outcome TEXT,\n",
    "      approved_expected_outcome TEXT,\n      approved_success_criteria TEXT,\n",
)

source = source.replace(
    "      expected_outcome TEXT,\n",
    "      expected_outcome TEXT,\n      success_criteria TEXT,\n",
    1,
)

source = source.replace(
    "      expected_outcome,\n      unresolved_questions,\n",
    "      expected_outcome,\n      success_criteria,\n      unresolved_questions,\n",
)

source = source.replace(
    """      'Prior approved outcome.',
      'canonical_approved',""",
    """      'Prior approved outcome.',
      'Prior approved success criteria.',
      'canonical_approved',""",
)

source = source.replace(
    """      approved_expected_outcome,
      approval_actor,""",
    """      approved_expected_outcome,
      approved_success_criteria,
      approval_actor,""",
)

source = source.replace(
    """        approved_expected_outcome: string;
      };""",
    """        approved_expected_outcome: string;
        approved_success_criteria: string;
      };""",
)

source = source.replace(
    """          approved_expected_outcome: "Prior approved outcome.",""",
    """          approved_expected_outcome: "Prior approved outcome.",
          approved_success_criteria: "Prior approved success criteria.",""",
)

source = source.replace(
    """    assert.equal(
      result.approved_expected_outcome,""",
    """    assert.equal(
      result.approved_success_criteria,
      "Completion is evaluated by preserving the authoritative Living Draft meaning through reconciliation.",
    );

    assert.equal(
      result.approved_expected_outcome,""",
)

path.write_text(source)

projection_test = Path("db/canonical-package-mission-projection.test.ts")
source = projection_test.read_text()

source = source.replace(
    "      approved_expected_outcome TEXT,\n",
    "      approved_expected_outcome TEXT,\n      approved_success_criteria TEXT,\n",
)

source = source.replace(
    """    approved_expected_outcome = "Approved mission outcome",""",
    """    approved_expected_outcome = "Approved mission outcome",
    approved_success_criteria = "Mission success criteria",""",
)

source = source.replace(
    """      approved_expected_outcome,
      approved_scope,""",
    """      approved_expected_outcome,
      approved_success_criteria,
      approved_scope,""",
)

source = source.replace(
    """    approved_expected_outcome,
    approved_scope,""",
    """    approved_expected_outcome,
    approved_success_criteria,
    approved_scope,""",
)

source = source.replace(
    "  assert.equal(row.success_criteria, null);",
    '  assert.equal(row.success_criteria, "Mission success criteria");',
)

projection_test.write_text(source)

read_test = Path("db/canonical-package-read-repository.delegation.test.ts")
source = read_test.read_text()

source = source.replace(
    "      approved_expected_outcome TEXT,\n",
    "      approved_expected_outcome TEXT,\n      approved_success_criteria TEXT,\n",
)

source = source.replace(
    """      approved_expected_outcome,
      approval_actor,""",
    """      approved_expected_outcome,
      approved_success_criteria,
      approval_actor,""",
)

read_test.write_text(source)

print("Canonical Package -> Governance success-criteria lineage implemented.")
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
  scripts/implement-canonical-success-criteria-lineage.sh

git add \
  db/matilda-canonical-package-runtime.ts \
  db/canonical-package-read-repository.ts \
  db/canonical-package-mission-projection.ts \
  db/matilda-canonical-package-runtime.test.ts \
  db/canonical-package-mission-projection.test.ts \
  db/canonical-package-read-repository.delegation.test.ts \
  scripts/implement-canonical-success-criteria-lineage.sh

git commit -m "Carry success criteria through canonical governance projection"
git push origin "$BRANCH"
