
import { assertEnvelopeCreationEligible } from "../db/governance-lifecycle-enforcement.ts";

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

assertDoesNotThrow("canonical eligible envelope creation", () => {

  assertEnvelopeCreationEligible({

    validationResult: {

      validation_status: "VALIDATION_PASSED",

    },

    envelopeGate: {

      gate_status: "OPEN",

    },

  });

});

assertDoesNotThrow("current runtime eligible envelope creation", () => {

  assertEnvelopeCreationEligible({

    validationResult: {

      validation_status: "ready",

    },

    envelopeGate: {

      gate_status: "open",

    },

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

  });

});

assertThrows("missing validation input", () => {

  assertEnvelopeCreationEligible({

    envelopeGate: {

      gate_status: "OPEN",

    },

  });

});

assertThrows("missing gate input", () => {

  assertEnvelopeCreationEligible({

    validationResult: {

      validation_status: "VALIDATION_PASSED",

    },

  });

});

console.log("PASS smoke-governance-lifecycle-enforcement");

