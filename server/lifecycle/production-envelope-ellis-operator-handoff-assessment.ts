/**
 * Non-mutating Envelope-to-Ellis operator handoff assessment.
 *
 * This module checks the internal consistency of caller-supplied assertions.
 * It does not independently verify operator identity, authorization,
 * department eligibility, acknowledgement, capability, or provenance.
 *
 * A successful assessment is not trusted evidence of production readiness.
 * It cannot authorize assignment, persistence, lifecycle transition,
 * credential issuance, execution, or any other production effect.
 */

export type EnvelopeEllisOperatorHandoffAssessmentInput = Readonly<{
  envelope_id: string;
  envelope_lifecycle_state: string;
  package_id: string;
  package_version: number;
  envelope_package_id: string;
  envelope_package_version: number;
  selected_department_id: string;
  eligible_department_ids: readonly string[];
  operator_authorization_id?: string;
  operator_authorization_verified?: boolean;
  department_acknowledgement_verified?: boolean;
  department_capability_confirmed?: boolean;
}>;

export type EnvelopeEllisOperatorHandoffAssessmentResult = Readonly<{
  assessment: "envelope_to_ellis_operator_handoff";
  ok: boolean;
  assessment_ready: boolean;
  production_transition_authorized: false;
  assignment_authorized: false;
  lifecycle_transition_authorized: false;
  credential_issuance_authorized: false;
  execution_authorized: false;
  new_authority_introduced: false;
  findings: readonly string[];
}>;

export function assessEnvelopeEllisOperatorHandoff(
  input: EnvelopeEllisOperatorHandoffAssessmentInput,
): EnvelopeEllisOperatorHandoffAssessmentResult {
  const findings: string[] = [];

  const envelopeId =
    typeof input.envelope_id === "string"
      ? input.envelope_id.trim()
      : "";

  const packageId =
    typeof input.package_id === "string"
      ? input.package_id.trim()
      : "";

  const envelopePackageId =
    typeof input.envelope_package_id === "string"
      ? input.envelope_package_id.trim()
      : "";

  const departmentId =
    typeof input.selected_department_id === "string"
      ? input.selected_department_id.trim()
      : "";

  const operatorAuthorizationId =
    typeof input.operator_authorization_id === "string"
      ? input.operator_authorization_id.trim()
      : "";

  if (!envelopeId) {
    findings.push("An exact governance Envelope ID is required.");
  }

  if (input.envelope_lifecycle_state !== "ENVELOPE_CREATED") {
    findings.push("The Envelope must remain in ENVELOPE_CREATED.");
  }

  if (
    !packageId ||
    !envelopePackageId ||
    packageId !== envelopePackageId ||
    !Number.isSafeInteger(input.package_version) ||
    input.package_version < 1 ||
    !Number.isSafeInteger(input.envelope_package_version) ||
    input.envelope_package_version < 1 ||
    input.package_version !== input.envelope_package_version
  ) {
    findings.push(
      "Supplied canonical package ID and version lineage must match.",
    );
  }

  if (
    !departmentId ||
    !Array.isArray(input.eligible_department_ids) ||
    !input.eligible_department_ids.includes(departmentId)
  ) {
    findings.push(
      "The selected department must appear in the supplied eligibility list.",
    );
  }

  if (
    !operatorAuthorizationId ||
    input.operator_authorization_verified !== true
  ) {
    findings.push(
      "A claimed operator authorization ID and affirmative verification assertion are required.",
    );
  }

  if (input.department_acknowledgement_verified !== true) {
    findings.push(
      "An affirmative departmental acknowledgement assertion is required.",
    );
  }

  if (input.department_capability_confirmed !== true) {
    findings.push(
      "An affirmative departmental capability assertion is required.",
    );
  }

  const assessmentReady = findings.length === 0;

  if (assessmentReady) {
    findings.push(
      "Caller-supplied handoff assertions are internally consistent; their provenance and authenticity have not been independently verified.",
    );
  }

  findings.push(
    "This assessment grants no production authority and must not be used as a trusted lifecycle or execution admission decision.",
  );

  return {
    assessment: "envelope_to_ellis_operator_handoff",
    ok: assessmentReady,
    assessment_ready: assessmentReady,
    production_transition_authorized: false,
    assignment_authorized: false,
    lifecycle_transition_authorized: false,
    credential_issuance_authorized: false,
    execution_authorized: false,
    new_authority_introduced: false,
    findings,
  };
}
