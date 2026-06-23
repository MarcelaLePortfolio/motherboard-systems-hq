
export type GovernanceValidationForEnvelopeCreation = {

  validation_status: string;

};

export type GovernanceEnvelopeGateForEnvelopeCreation = {

  gate_status: string;

};

export type GovernanceEnvelopeForCreation = {

  required_capabilities?: string | null;

  operational_corridor?: string | null;

};

export type GovernanceDelegationForValidation = {

  authorization_state: string;

};

export type AssertEnvelopeCreationEligibleInput = {

  validationResult: GovernanceValidationForEnvelopeCreation;

  envelopeGate: GovernanceEnvelopeGateForEnvelopeCreation;

  envelope: GovernanceEnvelopeForCreation;

};

export type AssertValidationEligibleInput = {

  delegation: GovernanceDelegationForValidation;

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

function requireLifecycleText(

  value: string | null | undefined,

  label: string,

): string {

  const normalized = value?.trim();

  if (!normalized) {

    throw new Error(`Missing governance lifecycle field: ${label}`);

  }

  return normalized;

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

function isDelegationAuthorized(authorizationState: string): boolean {

  return normalizeLifecycleStatus(authorizationState) === "AUTHORIZED";

}

export function assertValidationEligible(

  input: AssertValidationEligibleInput,

): void {

  const delegation = requireLifecycleInput(input?.delegation, "delegation");

  if (!isDelegationAuthorized(delegation.authorization_state)) {

    throw new Error(

      `Governance Validation ineligible: Delegation is not authorized (${delegation.authorization_state})`,

    );

  }

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

  const envelope = requireLifecycleInput(input?.envelope, "envelope");

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

  requireLifecycleText(envelope.required_capabilities, "required_capabilities");

  requireLifecycleText(envelope.operational_corridor, "operational_corridor");

}

