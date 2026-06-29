
import { sqliteTable, text, integer, primaryKey } from "drizzle-orm/sqlite-core";

export const governance_packages = sqliteTable(

  "governance_packages",

  {

    package_id: text("package_id").notNull(),

    package_version: integer("package_version").notNull(),

    requested_outcome: text("requested_outcome"),

    scope: text("scope"),

    containment: text("containment"),

    constraints: text("constraints"),

    success_criteria: text("success_criteria"),

    context: text("context"),

    style_presentation_intent: text("style_presentation_intent"),

    exclusions: text("exclusions"),

    created_at: text("created_at").notNull(),

  },

  (table) => ({

    pk: primaryKey({ columns: [table.package_id, table.package_version] }),

  })

);

export const governance_delegations = sqliteTable("governance_delegations", {

  delegation_id: text("delegation_id").primaryKey(),

  package_id: text("package_id").notNull(),

  package_version: integer("package_version").notNull(),

  authorization_state: text("authorization_state").notNull(),

  authorization_timestamp: text("authorization_timestamp").notNull(),

  delegated_by: text("delegated_by").notNull(),

  created_at: text("created_at").notNull(),

});

export const governance_validation_results = sqliteTable("governance_validation_results", {

  validation_result_id: text("validation_result_id").primaryKey(),

  package_id: text("package_id").notNull(),

  package_version: integer("package_version").notNull(),

  delegation_id: text("delegation_id").notNull(),

  validation_status: text("validation_status").notNull(),

  governance_findings: text("governance_findings"),

  operational_requirements: text("operational_requirements"),

  capability_requirements: text("capability_requirements"),

  escalations: text("escalations"),

  validation_timestamp: text("validation_timestamp").notNull(),

  created_at: text("created_at").notNull(),

});

export const governance_envelope_gates = sqliteTable("governance_envelope_gates", {

  envelope_gate_id: text("envelope_gate_id").primaryKey(),

  package_id: text("package_id").notNull(),

  package_version: integer("package_version").notNull(),

  delegation_id: text("delegation_id").notNull(),

  validation_result_id: text("validation_result_id").notNull(),

  gate_status: text("gate_status").notNull(),

  gate_reason: text("gate_reason"),

  gate_decision_timestamp: text("gate_decision_timestamp").notNull(),

  created_at: text("created_at").notNull(),

});

export const governance_envelopes = sqliteTable("governance_envelopes", {

  envelope_id: text("envelope_id").primaryKey(),

  package_id: text("package_id").notNull(),

  package_version: integer("package_version").notNull(),

  delegation_id: text("delegation_id").notNull(),

  validation_result_id: text("validation_result_id").notNull(),

  envelope_gate_id: text("envelope_gate_id").notNull(),

  validation_status: text("validation_status").notNull(),

  required_capabilities: text("required_capabilities"),

  operational_corridor: text("operational_corridor"),

  lifecycle_state: text("lifecycle_state").notNull(),

  created_at: text("created_at").notNull(),

});

export const operational_intake_records = sqliteTable("operational_intake_records", {

  intake_id: text("intake_id").primaryKey(),

  envelope_id: text("envelope_id").notNull(),

  package_id: text("package_id").notNull(),

  package_version: integer("package_version").notNull(),

  delegation_id: text("delegation_id").notNull(),

  validation_result_id: text("validation_result_id").notNull(),

  envelope_gate_id: text("envelope_gate_id").notNull(),

  lifecycle_state_at_intake: text("lifecycle_state_at_intake").notNull(),

  assigned_department: text("assigned_department").notNull(),

  required_capabilities_snapshot: text("required_capabilities_snapshot"),

  intake_status: text("intake_status").notNull(),

  intake_created_at: text("intake_created_at").notNull(),

  intake_updated_at: text("intake_updated_at").notNull(),

  governance_authority_preserved: integer("governance_authority_preserved").notNull(),

  lifecycle_authority_preserved: integer("lifecycle_authority_preserved").notNull(),

  assignment_authority_preserved: integer("assignment_authority_preserved").notNull(),

  routing_authorized: integer("routing_authorized").notNull(),

  scheduler_authorized: integer("scheduler_authorized").notNull(),

  worker_claim_authorized: integer("worker_claim_authorized").notNull(),

  execution_authorized: integer("execution_authorized").notNull(),

});

