from pathlib import Path

def replace(path, old, new, count=1):
    p = Path(path)
    s = p.read_text()
    if old not in s:
        raise SystemExit(f"Expected anchor not found in {path}:\n{old}")
    p.write_text(s.replace(old, new, count))

replace(
    "scripts/utils/ollamaChat.ts",
    """  expectedOutcome: string | null;
  proposedWork: string | null;""",
    """  expectedOutcome: string | null;
  successCriteria: string | null;
  proposedWork: string | null;"""
)

replace(
    "scripts/utils/ollamaChat.ts",
    '''"expectedOutcome",
  "proposedWork",''',
    '''"expectedOutcome",
  "successCriteria",
  "proposedWork",'''
)

replace(
    "server/matilda-chat-workflow.ts",
    """    expectedOutcome?: string | null;
    proposedWork?: string | null;""",
    """    expectedOutcome?: string | null;
    successCriteria?: string | null;
    proposedWork?: string | null;"""
)

replace(
    "db/matilda-living-draft-runtime.ts",
    """      expected_outcome TEXT,
      unresolved_questions TEXT,""",
    """      expected_outcome TEXT,
      success_criteria TEXT,
      unresolved_questions TEXT,"""
)

replace(
    "db/matilda-living-draft-runtime.ts",
    """  ensureColumn("expected_outcome", "TEXT");
  ensureColumn("unresolved_questions", "TEXT");""",
    """  ensureColumn("expected_outcome", "TEXT");
  ensureColumn("success_criteria", "TEXT");
  ensureColumn("unresolved_questions", "TEXT");"""
)

replace(
    "db/matilda-living-draft-read-runtime.ts",
    """      expected_outcome,
      unresolved_questions,""",
    """      expected_outcome,
      success_criteria,
      unresolved_questions,"""
)

replace(
    "db/matilda-draft-synthesis-runtime.ts",
    """      expected_outcome: selectedPackageSemantics.expectedOutcome,""",
    """      expected_outcome: selectedPackageSemantics.expectedOutcome,
      success_criteria: selectedPackageSemantics.successCriteria,"""
)

replace(
    "db/matilda-draft-revision-runtime.ts",
    """  expected_outcome: string | null;
  unresolved_questions: string | null;""",
    """  expected_outcome: string | null;
  success_criteria: string | null;
  unresolved_questions: string | null;"""
)

replace(
    "db/matilda-reconciled-intent-runtime.ts",
    """  expected_outcome: string | null;
  unresolved_questions: string | null;""",
    """  expected_outcome: string | null;
  success_criteria: string | null;
  unresolved_questions: string | null;"""
)

replace(
    "db/matilda-canonical-package-runtime.ts",
    """      approved_expected_outcome TEXT,
      approval_actor TEXT NOT NULL,""",
    """      approved_expected_outcome TEXT,
      approved_success_criteria TEXT,
      approval_actor TEXT NOT NULL,"""
)

replace(
    "db/matilda-canonical-package-runtime.ts",
    """  ensureColumn("approved_expected_outcome", "TEXT");""",
    """  ensureColumn("approved_expected_outcome", "TEXT");
  ensureColumn("approved_success_criteria", "TEXT");"""
)

replace(
    "db/canonical-package-read-repository.ts",
    """  approved_expected_outcome: string | null;
  approval_actor: string;""",
    """  approved_expected_outcome: string | null;
  approved_success_criteria: string | null;
  approval_actor: string;"""
)

replace(
    "db/canonical-package-mission-projection.ts",
    """  approved_expected_outcome: string | null;
  status: string;""",
    """  approved_expected_outcome: string | null;
  approved_success_criteria: string | null;
  status: string;"""
)

print("Bounded future-lineage edits applied.")
