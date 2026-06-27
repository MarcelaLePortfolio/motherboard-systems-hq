
import test from "node:test";

import assert from "node:assert/strict";

import {

  invokeProductionPackageEntryPoint,

  type GovernancePackagePersistenceFunction,

} from "./production-package-entry-point";

const fakeCreatePackage: GovernancePackagePersistenceFunction = (input) => ({

  package_id: input.package_id,

  package_version: input.package_version,

  created_at: "2026-06-26T22:02:08.000Z",

});

test(

  "production Package entry point creates only the canonical meaning artifact",

  () => {

    const result = invokeProductionPackageEntryPoint({

      package_id: "pkg-production-package-entry-point-success",

      package_version: 1,

      requested_outcome: "Create first canonical governance Package",

      scope: "Package surface only",

      containment: "No downstream governance artifacts",

      constraints: "No new authority",

      success_criteria: "Package is created",

      create_governance_package: fakeCreatePackage,

    });

    assert.equal(result.ok, true);

    assert.equal(result.entry_point, "production_package_entry_point");

    assert.equal(result.endpoint_authorized, false);

    assert.equal(result.scheduler_authorized, false);

    assert.equal(result.worker_claim_authorized, false);

    assert.equal(result.orchestration_authorized, false);

    assert.equal(result.routing_authorized, false);

    assert.equal(result.assignment_authorized, false);

    assert.equal(result.lifecycle_transition_authorized, false);

    assert.equal(result.execution_authorized, false);

    assert.equal(result.downstream_governance_authorized, false);

    assert.equal(result.new_authority_introduced, false);

    if (!result.ok) {

      assert.fail("Expected Package entry point to succeed.");

    }

    assert.equal(

      result.package.package_id,

      "pkg-production-package-entry-point-success",

    );

  },

);

test(

  "production Package entry point fails closed when persistence rejects input",

  () => {

    const result = invokeProductionPackageEntryPoint({

      package_id: "",

      package_version: 1,

      requested_outcome: "Missing package id",

      scope: "Package surface only",

      containment: "No downstream governance artifacts",

      constraints: "No new authority",

      success_criteria: "Package is rejected",

      create_governance_package: () => {

        throw new Error("package_id is required");

      },

    });

    assert.equal(result.ok, false);

    assert.equal(result.entry_point, "production_package_entry_point");

    assert.equal(result.endpoint_authorized, false);

    assert.equal(result.scheduler_authorized, false);

    assert.equal(result.worker_claim_authorized, false);

    assert.equal(result.orchestration_authorized, false);

    assert.equal(result.routing_authorized, false);

    assert.equal(result.assignment_authorized, false);

    assert.equal(result.lifecycle_transition_authorized, false);

    assert.equal(result.execution_authorized, false);

    assert.equal(result.downstream_governance_authorized, false);

    assert.equal(result.new_authority_introduced, false);

    assert.match(result.findings.join("\n"), /package_id is required/);

  },

);

