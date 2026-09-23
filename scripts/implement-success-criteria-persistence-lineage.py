from pathlib import Path

def replace(path, old, new, count=1):
    p = Path(path)
    text = p.read_text()
    if old not in text:
        raise SystemExit(f"Expected anchor not found in {path}:\n{old}")
    p.write_text(text.replace(old, new, count))

path = "db/matilda-living-draft-runtime.ts"

replace(
    path,
    """  expected_outcome?: string | null;

  unresolved_questions?: string | null;""",
    """  expected_outcome?: string | null;

  success_criteria?: string | null;

  unresolved_questions?: string | null;""",
)

replace(
    path,
    """      expected_outcome TEXT,

      unresolved_questions TEXT,""",
    """      expected_outcome TEXT,

      success_criteria TEXT,

      unresolved_questions TEXT,""",
)

replace(
    path,
    """  if (!columns.some((column) => column.name === "conversation_id")) {
    sqlite.exec(`
      ALTER TABLE matilda_living_draft_packages
      ADD COLUMN conversation_id TEXT;
    `);
  }""",
    """  if (!columns.some((column) => column.name === "conversation_id")) {
    sqlite.exec(`
      ALTER TABLE matilda_living_draft_packages
      ADD COLUMN conversation_id TEXT;
    `);
  }

  if (!columns.some((column) => column.name === "success_criteria")) {
    sqlite.exec(`
      ALTER TABLE matilda_living_draft_packages
      ADD COLUMN success_criteria TEXT;
    `);
  }""",
)

replace(
    path,
    """      expected_outcome,

      unresolved_questions,""",
    """      expected_outcome,

      success_criteria,

      unresolved_questions,""",
)

replace(
    path,
    """      @expected_outcome,

      @unresolved_questions,""",
    """      @expected_outcome,

      @success_criteria,

      @unresolved_questions,""",
)

replace(
    path,
    """      expected_outcome = excluded.expected_outcome,

      unresolved_questions = excluded.unresolved_questions,""",
    """      expected_outcome = excluded.expected_outcome,

      success_criteria = excluded.success_criteria,

      unresolved_questions = excluded.unresolved_questions,""",
)

replace(
    path,
    """    expected_outcome: optionalText(input.expected_outcome),

    unresolved_questions: optionalText(input.unresolved_questions),""",
    """    expected_outcome: optionalText(input.expected_outcome),

    success_criteria: optionalText(input.success_criteria),

    unresolved_questions: optionalText(input.unresolved_questions),""",
    2,
)

replace(
    "db/matilda-living-draft-read-runtime.ts",
    """      expected_outcome,
      unresolved_questions,""",
    """      expected_outcome,
      success_criteria,
      unresolved_questions,""",
)

print("Attempt 3 completes the verified Living Draft persistence boundary.")
