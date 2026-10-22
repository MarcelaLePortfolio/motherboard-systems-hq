/**
 * Non-mutating Envelope-to-Ellis operator handoff assessment.
 *
 * This module evaluates supplied evidence only.
 * It does not authenticate operators, verify credential provenance,
 * persist assignments, advance lifecycle state, invoke Ellis,
 * or grant execution authority.
 *
 * Successful assessment means supplied evidence is internally consistent.
 * It does not authorize a production lifecycle transition.
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

  const envelopeId = input.envelope_id?.trim();
  const packageId = input.package_id?.trim();
  const envelopePackageId = input.envelope_package_id?.trim();
  const departmentId = input.selected_department_id?.trim();

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
    findings.push("Exact canonical package ID and version lineage must match.");
  }

  if (
    !departmentId ||
    !Array.isArray(input.eligible_department_ids) ||
    !input.eligible_department_ids.includes(departmentId)
  ) {
    findings.push("The selected department must be capability-eligible.");
  }

  if (
    !input.operator_authorization_id?.trim() ||
    input.operator_authorization_verified !== true
  ) {
    findings.push("Independently verified operator authorization is required.");
  }

  if (input.department_acknowledgement_verified !== true) {
    findings.push("Verified departmental acknowledgement is required.");
  }

  if (input.department_capability_confirmed !== true) {
    findings.push("Verified departmental capability confirmation is required.");
  }

  const assessmentReady = findings.length === 0;

  if (assessmentReady) {
    findings.push(
      "Supplied handoff evidence is internally consistent; production authority remains separately blocked.",
    );
  }

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
