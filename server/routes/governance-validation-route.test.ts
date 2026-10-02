import test from "node:test";
import assert from "node:assert/strict";
import Database from "better-sqlite3";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

import {
  buildGovernanceValidationRouteRequest,
  handleGovernanceValidationRouteRequest,
} from "./governance-validation-route.ts";

function createFixture() {
  const directory = mkdtempSync(join(tmpdir(), "governance-validation-route-"));
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
    "pkg-route",
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

test("route request builder ignores caller-authored semantic Validation fields", () => {
  const request = buildGovernanceValidationRouteRequest({
    validation_result_id: "validation-route",
    package_id: "pkg-route",
    package_version: 1,
    delegation_id: "delegation-route",
    validation_timestamp: "2026-06-26T23:18:30.000Z",
    validation_status: "VALIDATION_PASSED",
    governance_findings: "caller supplied",
  } as Record<string, unknown>);

  assert.equal("validation_status" in request, false);
  assert.equal("governance_findings" in request, false);
});

test("route persists semantic adapter output and preserves authority boundary", async () => {
  const fixture = createFixture();

  try {
    const result = await handleGovernanceValidationRouteRequest(
      {
        validation_result_id: "validation-route",
        package_id: "pkg-route",
        package_version: 1,
        delegation_id: "delegation-route",
      },
      {
        database_path: fixture.databasePath,
        load_exact_governance_delegation: authorizedDelegation,
        analyze_governance_validation_semantics: async () => ({
          validation_status: "VALIDATION_PASSED",
          governance_findings: "Semantic evidence validated.",
          operational_requirements: null,
          capability_requirements: null,
          escalations: null,
        }),
        create_governance_validation_result: (input) => ({
          validation_result_id: input.validation_result_id,
          package_id: input.package_id,
          package_version: input.package_version,
          delegation_id: input.delegation_id,
          validation_status: input.validation_status,
          validation_timestamp:
            input.validation_timestamp ?? "2026-06-26T23:18:30.000Z",
          created_at: "2026-06-26T23:18:30.000Z",
        }),
      },
    );

    assert.equal(result.ok, true);
    assert.equal(result.execution_authorized, false);
    assert.equal(result.downstream_governance_authorized, false);
    assert.equal(result.new_authority_introduced, false);
    if (!result.ok) assert.fail("Expected route success.");
    assert.equal(
      result.validation.validation.validation_status,
      "VALIDATION_PASSED",
    );
  } finally {
    fixture.cleanup();
  }
});
