
export const ACKNOWLEDGEMENT_STATUS = Object.freeze({

  ACKNOWLEDGED: "ACKNOWLEDGED",

});

export const CAPABILITY_STATUS = Object.freeze({

  CAPABILITY_CONFIRMED: "CAPABILITY_CONFIRMED",

  CAPABILITY_CONFLICT_REPORTED: "CAPABILITY_CONFLICT_REPORTED",

});

export function createDepartmentAssignmentHandshake({

  owning_department,

  assignment_basis,

  acknowledgement_status,

  capability_status,

  capability_conflicts = [],

  response_basis,

} = {}) {

  if (!owning_department || typeof owning_department !== "string") {

    throw new Error("owning_department is required");

  }

  if (!assignment_basis || typeof assignment_basis !== "string") {

    throw new Error("assignment_basis is required");

  }

  if (acknowledgement_status !== ACKNOWLEDGEMENT_STATUS.ACKNOWLEDGED) {

    throw new Error("acknowledgement_status must be ACKNOWLEDGED");

  }

  if (!Object.values(CAPABILITY_STATUS).includes(capability_status)) {

    throw new Error("capability_status is invalid");

  }

  if (!Array.isArray(capability_conflicts)) {

    throw new Error("capability_conflicts must be an array");

  }

  if (

    capability_status === CAPABILITY_STATUS.CAPABILITY_CONFLICT_REPORTED &&

    capability_conflicts.length === 0

  ) {

    throw new Error(

      "capability_conflicts are required when capability conflict is reported"

    );

  }

  if (!response_basis || typeof response_basis !== "string") {

    throw new Error("response_basis is required");

  }

  return Object.freeze({

    owning_department,

    assignment_basis,

    acknowledgement_status,

    capability_status,

    capability_conflicts: Object.freeze([...capability_conflicts]),

    response_basis,

    may_proceed:

      capability_status === CAPABILITY_STATUS.CAPABILITY_CONFIRMED,

    requires_ellis_recoordination:

      capability_status ===

      CAPABILITY_STATUS.CAPABILITY_CONFLICT_REPORTED,

    scheduler_authorized: false,

    routing_authorized: false,

    worker_claim_authorized: false,

    execution_authorized: false,

    actor_assignment_authorized: false,

    participation_resolution_authorized: false,

    new_authority_introduced: false,

  });

}

