
export type GovernanceValidationForEnvelopeCreation = {

  validation_status: string;

};

export type GovernanceEnvelopeGateForEnvelopeCreation = {

  gate_status: string;

};

export type AssertEnvelopeCreationEligibleInput = {

  validationResult: GovernanceValidationForEnvelopeCreation;

  envelopeGate: GovernanceEnvelopeGateForEnvelopeCreation;

};

function requireLifecycleInput<T>(

  value: T | null | undefined,

  label: string,

): T {

  if (!value) {

    throw new Error(`Missing governance lifecycle input: ${label}`);

  }

  return value;

}

function normalizeLifecycleStatus(value: string): string {

  return value.trim().toUpperCase().replaceAll(" ", "_").replaceAll("-", "_");

}

function isValidationPassed(validationStatus: string): boolean {

  return normalizeLifecycleStatus(validationStatus) === "VALIDATION_PASSED";

}

function isEnvelopeGateOpen(gateStatus: string): boolean {

  return normalizeLifecycleStatus(gateStatus) === "OPEN";

}

export function assertEnvelopeCreationEligible(

  input: AssertEnvelopeCreationEligibleInput,

): void {

  const validationResult = requireLifecycleInput(

    input?.validationResult,

    "validationResult",

  );

  const envelopeGate = requireLifecycleInput(

    input?.envelopeGate,

    "envelopeGate",

  );

  if (!isValidationPassed(validationResult.validation_status)) {

    throw new Error(

      `Envelope creation ineligible: Governance Validation has not passed (${validationResult.validation_status})`,

    );

  }

  if (!isEnvelopeGateOpen(envelopeGate.gate_status)) {

    throw new Error(

      `Envelope creation ineligible: Envelope Gate is not open (${envelopeGate.gate_status})`,

    );

  }

}

