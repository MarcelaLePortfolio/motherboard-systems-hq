
import { sqliteTable, text, integer } from "drizzle-orm/sqlite-core";

export const governance_packages = sqliteTable("governance_packages", {

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

});

export const governance_delegations = sqliteTable("governance_delegations", {

  delegation_id: text("delegation_id").primaryKey(),

  package_id: text("package_id").notNull(),

  package_version: integer("package_version").notNull(),

  authorization_state: text("authorization_state").notNull(),

  authorization_timestamp: text("authorization_timestamp").notNull(),

  delegated_by: text("delegated_by").notNull(),

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

});

export const governance_envelope_gates = sqliteTable("governance_envelope_gates", {

  envelope_gate_id: text("envelope_gate_id").primaryKey(),

  package_id: text("package_id").notNull(),

  package_version: integer("package_version").notNull(),

  validation_result_id: text("validation_result_id").notNull(),

  gate_status: text("gate_status").notNull(),

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

