#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
BASELINE="16d5df200"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 '@{u}')" = "$BASELINE"

python3 - <<'PY'
from pathlib import Path

def replace(path_name: str, old: str, new: str, count: int = 1):
    path = Path(path_name)
    source = path.read_text()

    if source.count(old) < count:
        raise SystemExit(
            f"Expected anchor not found enough times in {path_name}:\n{old}"
        )

    path.write_text(source.replace(old, new, count))


revision = "db/matilda-draft-revision-runtime.ts"

replace(
    revision,
    """  expected_outcome: string | null;
  unresolved_questions: string | null;""",
    """  expected_outcome: string | null;
  success_criteria: string | null;
  unresolved_questions: string | null;""",
)

replace(
    revision,
    """      expected_outcome TEXT,
      unresolved_questions TEXT,""",
    """      expected_outcome TEXT,
      success_criteria TEXT,
      unresolved_questions TEXT,""",
)

path = Path(revision)
source = path.read_text()

anchor = """  sqlite.exec(`
    CREATE INDEX IF NOT EXISTS
      idx_matilda_draft_revisions_lineage_created"""

if anchor not in source:
    raise SystemExit("Draft Revision migration insertion anchor not found.")

migration = """  const columns = sqlite
    .prepare("PRAGMA table_info(matilda_draft_revisions)")
    .all() as Array<{ name: string }>;

  if (!columns.some((column) => column.name === "success_criteria")) {
    sqlite.exec(`
      ALTER TABLE matilda_draft_revisions
      ADD COLUMN success_criteria TEXT
    `);
  }

"""

source = source.replace(anchor, migration + anchor, 1)
path.write_text(source)

replace(
    revision,
    """        expected_outcome,
        unresolved_questions,""",
    """        expected_outcome,
        success_criteria,
        unresolved_questions,""",
)

replace(
    revision,
    """        ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
      )""",
    """        ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
      )""",
)

replace(
    revision,
    """      draft.expected_outcome,
      draft.unresolved_questions,""",
    """      draft.expected_outcome,
      draft.success_criteria,
      draft.unresolved_questions,""",
)


summary = "db/matilda-reconciled-intent-runtime.ts"

replace(
    summary,
    """  expected_outcome: string | null;
  unresolved_questions: string | null;""",
    """  expected_outcome: string | null;
  success_criteria: string | null;
  unresolved_questions: string | null;""",
    2,
)

replace(
    summary,
    """    expected_outcome: source.expected_outcome,
    unresolved_questions: source.unresolved_questions,""",
    """    expected_outcome: source.expected_outcome,
    success_criteria: source.success_criteria,
    unresolved_questions: source.unresolved_questions,""",
)

replace(
    summary,
    """      expected_outcome: revision.expected_outcome,
      unresolved_questions: revision.unresolved_questions,""",
    """      expected_outcome: revision.expected_outcome,
      success_criteria: revision.success_criteria,
      unresolved_questions: revision.unresolved_questions,""",
)

replace(
    summary,
    """    expected_outcome: draft.expected_outcome,
    unresolved_questions: draft.unresolved_questions,""",
    """    expected_outcome: draft.expected_outcome,
    success_criteria: draft.success_criteria,
    unresolved_questions: draft.unresolved_questions,""",
)

print("Draft Revision -> Reconciled Summary success-criteria boundary implemented.")
PY

npx tsc --noEmit

node --import tsx --test \
  db/matilda-reconciled-intent-runtime.test.ts \
  db/matilda-canonical-package-runtime.test.ts

git diff --check -- \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-reconciled-intent-runtime.ts

git diff -- \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-reconciled-intent-runtime.ts

git add \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-reconciled-intent-runtime.ts \
  scripts/implement-success-criteria-draft-revision-summary.sh

git commit -m "Carry success criteria through reconciled summary"
git push origin "$BRANCH"
