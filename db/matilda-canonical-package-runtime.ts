
import { randomUUID } from "node:crypto";

import Database from "better-sqlite3";

import { generateReconciledIntentSummary } from "./matilda-reconciled-intent-runtime.ts";

const sqlite = new Database("motherboard.sqlite");

function ensureCanonicalPackageTable() {

  sqlite.exec(`

    CREATE TABLE IF NOT EXISTS matilda_canonical_packages (

      package_id TEXT PRIMARY KEY,

      summary_id TEXT NOT NULL,

      draft_package_id TEXT NOT NULL,

      lineage_id TEXT NOT NULL,

      approved_interpretation TEXT NOT NULL,

      approved_work TEXT,

      approved_artifacts TEXT,

      approved_scope TEXT,

      approved_constraints TEXT,

      approved_expected_outcome TEXT,

      approval_actor TEXT NOT NULL,

      approval_timestamp TEXT NOT NULL,

      status TEXT NOT NULL,

      created_at TEXT NOT NULL

    )

  `);

}

export function createCanonicalPackageFromApprovedSummary({

  draft_package_id,

  approval_actor,

}: {

  draft_package_id: string;

  approval_actor: string;

}) {

  ensureCanonicalPackageTable();

  const summary = generateReconciledIntentSummary({ draft_package_id });

  if (summary.approval_required !== true) {

    throw new Error("Summary is not eligible for approval.");

  }

  const created_at = new Date().toISOString();

  const package_id = `pkg-${randomUUID()}`;

  sqlite.prepare(`

    INSERT INTO matilda_canonical_packages (

      package_id,

      summary_id,

      draft_package_id,

      lineage_id,

      approved_interpretation,

      approved_work,

      approved_artifacts,

      approved_scope,

      approved_constraints,

      approved_expected_outcome,

      approval_actor,

      approval_timestamp,

      status,

      created_at

    ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)

  `).run(

    package_id,

    summary.summary_id,

    summary.draft_package_id,

    summary.lineage_id,

    summary.interpreted_objective,

    summary.proposed_work,

    summary.proposed_artifacts,

    summary.in_scope,

    summary.constraints,

    summary.expected_outcome,

    approval_actor,

    created_at,

    "canonical_approved",

    created_at,

  );

  return {

    package_id,

    summary_id: summary.summary_id,

    draft_package_id: summary.draft_package_id,

    lineage_id: summary.lineage_id,

    approved_interpretation: summary.interpreted_objective,

    approved_work: summary.proposed_work,

    approved_artifacts: summary.proposed_artifacts,

    approved_scope: summary.in_scope,

    approved_constraints: summary.constraints,

    approved_expected_outcome: summary.expected_outcome,

    approval_actor,

    approval_timestamp: created_at,

    status: "canonical_approved",

    created_at,

    delegation_authorized: false,

    validation_authorized: false,

    envelope_authorized: false,

    execution_authorized: false,

  };

}

