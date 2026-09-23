from pathlib import Path

def replace(path_name: str, old: str, new: str, count: int = 1):
    path = Path(path_name)
    source = path.read_text()

    if old not in source:
        raise SystemExit(
            f"Expected anchor not found in {path_name}:\n{old}"
        )

    path.write_text(source.replace(old, new, count))


# ------------------------------------------------------------
# Draft Revision
# ------------------------------------------------------------

replace(
    "db/matilda-draft-revision-runtime.ts",
    """      expected_outcome TEXT,
      unresolved_questions TEXT,""",
    """      expected_outcome TEXT,
      success_criteria TEXT,
      unresolved_questions TEXT,""",
)

replace(
    "db/matilda-draft-revision-runtime.ts",
    """  expected_outcome: string | null;
  unresolved_questions: string | null;""",
    """  expected_outcome: string | null;
  success_criteria: string | null;
  unresolved_questions: string | null;""",
)

replace(
    "db/matilda-draft-revision-runtime.ts",
    """    expected_outcome: row.expected_outcome,
    unresolved_questions: row.unresolved_questions,""",
    """    expected_outcome: row.expected_outcome,
    success_criteria: row.success_criteria,
    unresolved_questions: row.unresolved_questions,""",
)

replace(
    "db/matilda-draft-revision-runtime.ts",
    """        expected_outcome,
        unresolved_questions,
        evidence_entry_ids,""",
    """        expected_outcome,
        success_criteria,
        unresolved_questions,
        evidence_entry_ids,""",
)

replace(
    "db/matilda-draft-revision-runtime.ts",
    """      ) VALUES (
        ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
      )""",
    """      ) VALUES (
        ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
      )""",
)

replace(
    "db/matilda-draft-revision-runtime.ts",
    """      draft.expected_outcome,
      draft.unresolved_questions,""",
    """      draft.expected_outcome,
      draft.success_criteria,
      draft.unresolved_questions,""",
)


# ------------------------------------------------------------
# Reconciled Summary
# ------------------------------------------------------------

replace(
    "db/matilda-reconciled-intent-runtime.ts",
    """  expected_outcome: string | null;
  unresolved_questions: string | null;""",
    """  expected_outcome: string | null;
  success_criteria: string | null;
  unresolved_questions: string | null;""",
    2,
)

replace(
    "db/matilda-reconciled-intent-runtime.ts",
    """    expected_outcome: source.expected_outcome,
    unresolved_questions: source.unresolved_questions,""",
    """    expected_outcome: source.expected_outcome,
    success_criteria: source.success_criteria,
    unresolved_questions: source.unresolved_questions,""",
)

replace(
    "db/matilda-reconciled-intent-runtime.ts",
    """      expected_outcome: revision.expected_outcome,
      unresolved_questions: revision.unresolved_questions,""",
    """      expected_outcome: revision.expected_outcome,
      success_criteria: revision.success_criteria,
      unresolved_questions: revision.unresolved_questions,""",
)

replace(
    "db/matilda-reconciled-intent-runtime.ts",
    """    expected_outcome: draft.expected_outcome,
    unresolved_questions: draft.unresolved_questions,""",
    """    expected_outcome: draft.expected_outcome,
    success_criteria: draft.success_criteria,
    unresolved_questions: draft.unresolved_questions,""",
)

print(
    "Success criteria now carries through Draft Revision "
    "and Reconciled Summary."
)
