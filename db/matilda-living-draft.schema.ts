
import { sqliteTable, text } from "drizzle-orm/sqlite-core";

export const matilda_living_draft_packages = sqliteTable(

  "matilda_living_draft_packages",

  {

    draft_package_id: text("draft_package_id").primaryKey(),

    lineage_id: text("lineage_id").notNull(),

    project_id: text("project_id"),

    conversation_id: text("conversation_id"),

    current_interpretation: text("current_interpretation").notNull(),

    proposed_work: text("proposed_work"),

    proposed_artifacts: text("proposed_artifacts"),

    in_scope: text("in_scope"),

    out_of_scope: text("out_of_scope"),

    constraints: text("constraints"),

    expected_outcome: text("expected_outcome"),

    unresolved_questions: text("unresolved_questions"),

    evidence_entry_ids: text("evidence_entry_ids").notNull(),

    status: text("status").notNull(),

    created_at: text("created_at").notNull(),

    updated_at: text("updated_at").notNull(),

  }

);

