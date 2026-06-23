
import {

  assertEnvelopeCreationEligible,

  assertValidationEligible,

} from "../db/governance-lifecycle-enforcement.ts";

function assert(condition, message) {

  if (!condition) {

    throw new Error(message);

  }

}

function assertThrows(label, fn) {

  let threw = false;

  try {

    fn();

  } catch {

    threw = true;

  }

  assert(threw, `${label} should throw`);

}

function assertDoesNotThrow(label, fn) {

  try {

    fn();

  } catch (error) {

    throw new Error(`${label} should not throw: ${error?.message ?? error}`);

  }

}

const eligibleEnvelope = {

  required_capabilities: "engineering_planning,repository_analysis",

  operational_corridor: "planning_only",

};

assertDoesNotThrow("authorized validation eligibility", () => {

  assertValidationEligible({

    delegation: {

      authorization_state: "authorized",

    },

  });

});

assertDoesNotThrow("normalized authorized validation eligibility", () => {

  assertValidationEligible({

    delegation: {

      authorization_state: "AUTHORIZED",

    },

  });

});

assertThrows("missing delegation input", () => {

  assertValidationEligible({});

});

assertThrows("unauthorized delegation", () => {

  assertValidationEligible({

    delegation: {

      authorization_state: "pending",

    },

  });

});

assertThrows("blank delegation authorization state", () => {

  assertValidationEligible({

    delegation: {

      authorization_state: " ",

    },

  });

});

assertDoesNotThrow("canonical eligible envelope creation", () => {

  assertEnvelopeCreationEligible({

    validationResult: {

      validation_status: "VALIDATION_PASSED",

    },

    envelopeGate: {

      gate_status: "OPEN",

    },

    envelope: eligibleEnvelope,

  });

});

assertDoesNotThrow("normalized canonical eligible envelope creation", () => {

  assertEnvelopeCreationEligible({

    validationResult: {

      validation_status: "validation passed",

    },

    envelopeGate: {

      gate_status: "open",

    },

    envelope: eligibleEnvelope,

  });

});

assertThrows("runtime placeholder ready validation", () => {

  assertEnvelopeCreationEligible({

    validationResult: {

      validation_status: "ready",

    },

    envelopeGate: {

      gate_status: "open",

    },

    envelope: eligibleEnvelope,

  });

});

assertThrows("noncanonical passed validation alias", () => {

  assertEnvelopeCreationEligible({

    validationResult: {

      validation_status: "PASSED",

    },

    envelopeGate: {

      gate_status: "OPEN",

    },

    envelope: eligibleEnvelope,

  });

});

assertThrows("failed validation", () => {

  assertEnvelopeCreationEligible({

    validationResult: {

      validation_status: "VALIDATION_FAILED",

    },

    envelopeGate: {

      gate_status: "OPEN",

    },

    envelope: eligibleEnvelope,

  });

});

assertThrows("resolution required validation", () => {

  assertEnvelopeCreationEligible({

    validationResult: {

      validation_status: "VALIDATION_RESOLUTION_REQUIRED",

    },

    envelopeGate: {

      gate_status: "OPEN",

    },

    envelope: eligibleEnvelope,

  });

});

assertThrows("closed envelope gate", () => {

  assertEnvelopeCreationEligible({

    validationResult: {

      validation_status: "VALIDATION_PASSED",

    },

    envelopeGate: {

      gate_status: "CLOSED",

    },

    envelope: eligibleEnvelope,

  });

});

assertThrows("missing validation input", () => {

  assertEnvelopeCreationEligible({

    envelopeGate: {

      gate_status: "OPEN",

    },

    envelope: eligibleEnvelope,

  });

});

assertThrows("missing gate input", () => {

  assertEnvelopeCreationEligible({

    validationResult: {

      validation_status: "VALIDATION_PASSED",

    },

    envelope: eligibleEnvelope,

  });

});

assertThrows("missing envelope input", () => {

  assertEnvelopeCreationEligible({

    validationResult: {

      validation_status: "VALIDATION_PASSED",

    },

    envelopeGate: {

      gate_status: "OPEN",

    },

  });

});

assertThrows("missing required capabilities", () => {

  assertEnvelopeCreationEligible({

    validationResult: {

      validation_status: "VALIDATION_PASSED",

    },

    envelopeGate: {

      gate_status: "OPEN",

    },

    envelope: {

      operational_corridor: "planning_only",

    },

  });

});

assertThrows("missing operational corridor", () => {

  assertEnvelopeCreationEligible({

    validationResult: {

      validation_status: "VALIDATION_PASSED",

    },

    envelopeGate: {

      gate_status: "OPEN",

    },

    envelope: {

      required_capabilities: "engineering_planning",

    },

  });

});

console.log("Governance lifecycle enforcement smoke passed");

