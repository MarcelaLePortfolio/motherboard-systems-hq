
import test from "node:test";

import assert from "node:assert/strict";

import {

  ACKNOWLEDGEMENT_STATUS,

  CAPABILITY_STATUS,

  createDepartmentAssignmentHandshake,

} from "./governance-department-assignment-handshake.mjs";

test("successful acknowledgement", () => {

  const result = createDepartmentAssignmentHandshake({

    owning_department: "engineering",

    assignment_basis: "Capability resolution completed by Ellis.",

    acknowledgement_status: ACKNOWLEDGEMENT_STATUS.ACKNOWLEDGED,

    capability_status: CAPABILITY_STATUS.CAPABILITY_CONFIRMED,

    response_basis: "Department confirms capability.",

  });

  assert.equal(result.may_proceed, true);

  assert.equal(result.requires_ellis_recoordination, false);

  assert.equal(result.execution_authorized, false);

});

test("capability conflict", () => {

  const result = createDepartmentAssignmentHandshake({

    owning_department: "engineering",

    assignment_basis: "Capability resolution completed by Ellis.",

    acknowledgement_status: ACKNOWLEDGEMENT_STATUS.ACKNOWLEDGED,

    capability_status:

      CAPABILITY_STATUS.CAPABILITY_CONFLICT_REPORTED,

    capability_conflicts: ["database specialist unavailable"],

    response_basis: "Local operational conflict detected.",

  });

  assert.equal(result.may_proceed, false);

  assert.equal(result.requires_ellis_recoordination, true);

});

test("conflict requires evidence", () => {

  assert.throws(() =>

    createDepartmentAssignmentHandshake({

      owning_department: "engineering",

      assignment_basis: "Capability resolution completed by Ellis.",

      acknowledgement_status:

        ACKNOWLEDGEMENT_STATUS.ACKNOWLEDGED,

      capability_status:

        CAPABILITY_STATUS.CAPABILITY_CONFLICT_REPORTED,

      response_basis: "Conflict.",

    })

  );

});

