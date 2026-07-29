import Database from "better-sqlite3";

const sqlite = new Database("db/main.db");
sqlite.pragma("foreign_keys = ON");

export function getLivingDraftPackageById(draft_package_id: string) {
  const draft = sqlite.prepare(`
    SELECT
      draft_package_id,
      lineage_id,
      project_id,
      conversation_id,
      current_interpretation,
      proposed_work,
      proposed_artifacts,
      in_scope,
      out_of_scope,
      constraints,
      expected_outcome,
      unresolved_questions,
      evidence_entry_ids,
      status,
      created_at,
      updated_at
    FROM matilda_living_draft_packages
    WHERE draft_package_id = ?
    LIMIT 1
  `).get(draft_package_id) as any;

  if (!draft) {
    throw new Error(`Living Draft Package not found: ${draft_package_id}`);
  }

  return {
    ...draft,
    evidence_entry_ids: JSON.parse(draft.evidence_entry_ids || "[]"),
  };
}
