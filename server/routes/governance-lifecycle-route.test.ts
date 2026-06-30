
import test from "node:test";

import assert from "node:assert/strict";

import {

  buildGovernanceLifecycleRouteRequest,

  handleGovernanceLifecycleRouteRequest,

} from "./governance-lifecycle-route.ts";

import type {

  GovernanceLifecyclePersistenceFunction,

} from "../../db/governance-lifecycle-composition.ts";

const departmentHandshake = {

  acknowledgement_status: "ACKNOWLEDGED" as const,

  capability_status: "CAPABILITY_CONFIRMED" as const,

  response_basis: "Department confirms current capability.",

};

const fakePersist: GovernanceLifecyclePersistenceFunction = ({

  envelope_id,

  transition_authorization,

  persisted_at,

}) => ({

  envelope_id,

  previous_lifecycle_state: transition_authorization.from,

  lifecycle_state: transition_authorization.to,

  transition: "ENVELOPE_CREATED_TO_ASSIGNED",

  persisted_at: persisted_at ?? "2026-06-26T10:39:38.000Z",

  mutation_authorized: false,

  execution_authorized: false,

});

const fakeOperationalIntake = ({

  intake_id,

  envelope_id,

  assigned_department,

  intake_created_at,

}: {

  intake_id: string;

  envelope_id: string;

  assigned_department: string;

  intake_created_at?: string | null;

}) => ({

  intake_id,

  envelope_id,

  package_id: "pkg-governance-lifecycle-route-success",

  package_version: 1,

  delegation_id: "del-governance-lifecycle-route-success",

  validation_result_id: "val-governance-lifecycle-route-success",

  envelope_gate_id: "gate-governance-lifecycle-route-success",

  lifecycle_state_at_intake: "ASSIGNED" as const,

  assigned_department,

  required_capabilities_snapshot: "engineering",

  intake_status: "RECORDED" as const,

  intake_created_at: intake_created_at ?? "2026-06-26T10:39:38.000Z",

  intake_updated_at: intake_created_at ?? "2026-06-26T10:39:38.000Z",

  governance_authority_preserved: true as const,

  lifecycle_authority_preserved: true as const,

  assignment_authority_preserved: true as const,

  routing_authorized: false as const,

  scheduler_authorized: false as const,

  worker_claim_authorized: false as const,

  execution_authorized: false as const,

});

test(

  "governance lifecycle route request builder normalizes body without adding execution authority",

  () => {

    const request = buildGovernanceLifecycleRouteRequest({

      envelope_id: "env-governance-lifecycle-route-builder",

      envelope: {

        lifecycle_state: "ENVELOPE_CREATED",

        required_capabilities: "engineering",

        operational_corridor: "governance lifecycle route test",

      },

      available_departments: ["engineering"],

      department_handshake: departmentHandshake,

    });

    assert.equal(request.envelope_id, "env-governance-lifecycle-route-builder");

    assert.deepEqual(request.available_departments, ["engineering"]);

    assert.equal(request.department_handshake, departmentHandshake);

    assert.equal("available_actors" in request, false);

    assert.equal(request.target_lifecycle_state, undefined);

  },

);

test(

  "governance lifecycle route handler invokes lifecycle consumer with injected persistence and operational intake",

  () => {

    const result = handleGovernanceLifecycleRouteRequest(

      {

        envelope_id: "env-governance-lifecycle-route-success",

        envelope: {

          lifecycle_state: "ENVELOPE_CREATED",

          required_capabilities: "engineering",

          operational_corridor: "governance lifecycle route test",

        },

        available_departments: ["engineering"],

        department_handshake: departmentHandshake,

      },

      {

        persist_lifecycle_transition: fakePersist,

        create_operational_intake: fakeOperationalIntake,

      },

    );

    assert.equal(result.ok, true);

    assert.equal(result.route, "governance_lifecycle_route");

    assert.equal(result.endpoint_authorized, true);

    assert.equal(result.scheduler_authorized, false);

    assert.equal(result.worker_claim_authorized, false);

    assert.equal(result.orchestration_authorized, false);

    assert.equal(result.routing_authorized, false);

    assert.equal(result.execution_authorized, false);

    assert.equal(result.new_authority_introduced, false);

    if (!result.ok) {

      assert.fail("Expected route handler to succeed.");

    }

    assert.equal(result.lifecycle.lifecycle.persistence.lifecycle_state, "ASSIGNED");

    assert.equal(result.lifecycle.operational_intake.lifecycle_state_at_intake, "ASSIGNED");

    assert.equal(result.lifecycle.operational_intake.assigned_department, "engineering");

    assert.equal(result.lifecycle.operational_intake.execution_authorized, false);

    assert.equal("assigned_actor" in result.lifecycle.lifecycle.persistence, false);

  },

);

test(

  "governance lifecycle route handler fails closed before persistence",

  () => {

    let persistCalled = false;

    let intakeCalled = false;

    const result = handleGovernanceLifecycleRouteRequest(

      {

        envelope_id: "env-governance-lifecycle-route-blocked",

        envelope: {

          lifecycle_state: "ASSIGNED",

          required_capabilities: "engineering",

          operational_corridor: "governance lifecycle route test",

        },

        available_departments: ["engineering"],

        department_handshake: departmentHandshake,

      },

      {

        persist_lifecycle_transition: (input) => {

          persistCalled = true;

          return fakePersist(input);

        },

        create_operational_intake: (input) => {

          intakeCalled = true;

          return fakeOperationalIntake(input);

        },

      },

    );

    assert.equal(result.ok, false);

    assert.equal(persistCalled, false);

    assert.equal(intakeCalled, false);

    assert.equal(result.route, "governance_lifecycle_route");

    assert.equal(result.endpoint_authorized, true);

  },

);

test(

  "governance lifecycle route handler fails closed on capability conflict before persistence",

  () => {

    let persistCalled = false;

    let intakeCalled = false;

    const result = handleGovernanceLifecycleRouteRequest(

      {

        envelope_id: "env-governance-lifecycle-route-conflict",

        envelope: {

          lifecycle_state: "ENVELOPE_CREATED",

          required_capabilities: "engineering",

          operational_corridor: "governance lifecycle route test",

        },

        available_departments: ["engineering"],

        department_handshake: {

          acknowledgement_status: "ACKNOWLEDGED",

          capability_status: "CAPABILITY_CONFLICT_REPORTED",

          capability_conflicts: ["engineering unavailable"],

          response_basis: "Department reports a capability conflict.",

        },

      },

      {

        persist_lifecycle_transition: (input) => {

          persistCalled = true;

          return fakePersist(input);

        },

        create_operational_intake: (input) => {

          intakeCalled = true;

          return fakeOperationalIntake(input);

        },

      },

    );

    assert.equal(result.ok, false);

    assert.equal(persistCalled, false);

    assert.equal(intakeCalled, false);

    assert.equal(result.route, "governance_lifecycle_route");

    assert.equal(result.endpoint_authorized, true);

  },

);

