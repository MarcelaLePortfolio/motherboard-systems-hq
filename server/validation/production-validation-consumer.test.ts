import test from "node:test";
import assert from "node:assert/strict";
import Database from "better-sqlite3";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { consumeProductionValidationEntryPoint } from "./production-validation-consumer.ts";

function createFixture() {
  const directory = mkdtempSync(join(tmpdir(), "production-validation-consumer-"));
  const databasePath = join(directory, "main.db");
  const db = new Database(databasePath);

  db.exec(`
    CREATE TABLE governance_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      project_id TEXT,
      requested_outcome TEXT,
      scope TEXT,
      constraints TEXT,
      success_criteria TEXT,
      PRIMARY KEY (package_id, package_version)
    );
  `);

  db.prepare(`
    INSERT INTO governance_packages (
      project_id,
      package_id,
      package_version,
      requested_outcome,
      scope,
      constraints,
      success_criteria
    ) VALUES (?, ?, ?, ?, ?, ?, ?)
  `).run(
    "hq",
    "pkg-1",
    1,
    "Deliver approved outcome.",
    "Approved scope.",
    "Preserve governance boundaries.",
    "Approved success criteria.",
  );

  db.close();

  return {
    databasePath,
    cleanup: () => rmSync(directory, { recursive: true, force: true }),
  };
}

function authorizedDelegation(identity: {
  delegation_id: string;
  package_id: string;
  package_version: number;
}) {
  return {
    delegation_id: identity.delegation_id,
    project_id: "hq",
    package_id: identity.package_id,
    package_version: identity.package_version,
    authorization_state: "AUTHORIZED",
  };
}

test("consumer persists semantic-adapter result rather than caller-authored PASS", async () => {
  const fixture = createFixture();
  let persistedStatus = "";

  try {
    const result = await consumeProductionValidationEntryPoint({
      validation_result_id: "validation-1",
      package_id: "pkg-1",
      package_version: 1,
      delegation_id: "delegation-1",
      database_path: fixture.databasePath,
      load_exact_governance_delegation: authorizedDelegation,
      analyze_governance_validation_semantics: async () => ({
        validation_status: "RESOLUTION_REQUIRED",
        governance_findings: "Semantic ambiguity remains.",
        operational_requirements: "Clarify success criteria.",
        capability_requirements: null,
        escalations: null,
      }),
      create_governance_validation_result: (input) => {
        persistedStatus = input.validation_status;
        return {
          validation_result_id: input.validation_result_id,
          package_id: input.package_id,
          package_version: input.package_version,
          delegation_id: input.delegation_id,
          validation_status: input.validation_status,
          validation_timestamp:
            input.validation_timestamp ?? "2026-06-26T23:18:30.000Z",
          created_at: "2026-06-26T23:18:30.000Z",
        };
      },
    });

    assert.equal(result.ok, true);
    assert.equal(persistedStatus, "RESOLUTION_REQUIRED");
    assert.equal(result.execution_authorized, false);
    assert.equal(result.new_authority_introduced, false);
  } finally {
    fixture.cleanup();
  }
});

test("consumer persists exactly once when semantic adapter returns PASS", async () => {
  const fixture = createFixture();
  let persistenceCalls = 0;

  try {
    const result = await consumeProductionValidationEntryPoint({
      validation_result_id: "validation-2",
      package_id: "pkg-1",
      package_version: 1,
      delegation_id: "delegation-1",
      database_path: fixture.databasePath,
      load_exact_governance_delegation: authorizedDelegation,
      analyze_governance_validation_semantics: async () => ({
        validation_status: "VALIDATION_PASSED",
        governance_findings: "Evidence is coherent.",
        operational_requirements: null,
        capability_requirements: null,
        escalations: null,
      }),
      create_governance_validation_result: (input) => {
        persistenceCalls += 1;
        return {
          validation_result_id: input.validation_result_id,
          package_id: input.package_id,
          package_version: input.package_version,
          delegation_id: input.delegation_id,
          validation_status: input.validation_status,
          validation_timestamp:
            input.validation_timestamp ?? "2026-06-26T23:18:30.000Z",
          created_at: "2026-06-26T23:18:30.000Z",
        };
      },
    });

    assert.equal(result.ok, true);
    assert.equal(persistenceCalls, 1);
    if (!result.ok) assert.fail("Expected semantic Validation to persist.");
    assert.equal(result.validation.validation_status, "VALIDATION_PASSED");
    assert.equal(result.execution_authorized, false);
    assert.equal(result.new_authority_introduced, false);
  } finally {
    fixture.cleanup();
  }
});

test("consumer fails closed before semantic analysis for unauthorized Delegation", async () => {
  const fixture = createFixture();
  let semanticCalls = 0;
  let persistenceCalls = 0;

  try {
    const result = await consumeProductionValidationEntryPoint({
      validation_result_id: "validation-3",
      package_id: "pkg-1",
      package_version: 1,
      delegation_id: "delegation-1",
      database_path: fixture.databasePath,
      load_exact_governance_delegation: (identity) => ({
        delegation_id: identity.delegation_id,
        project_id: "hq",
        package_id: identity.package_id,
        package_version: identity.package_version,
        authorization_state: "PENDING",
      }),
      analyze_governance_validation_semantics: async () => {
        semanticCalls += 1;
        throw new Error("must not run");
      },
      create_governance_validation_result: () => {
        persistenceCalls += 1;
        throw new Error("must not run");
      },
    });

    assert.equal(result.ok, false);
    assert.equal(semanticCalls, 0);
    assert.equal(persistenceCalls, 0);
    assert.match(result.findings.join("\n"), /not authorized/i);
    assert.equal(result.execution_authorized, false);
    assert.equal(result.new_authority_introduced, false);
  } finally {
    fixture.cleanup();
  }
});
