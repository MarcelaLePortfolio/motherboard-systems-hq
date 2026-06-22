
import Database from "better-sqlite3";

export type CreateGovernancePackageInput = {

  package_id: string;

  package_version: number;

  requested_outcome: string;

  scope: string;

  containment: string;

  constraints: string;

  success_criteria: string;

  context?: string | null;

  style_presentation_intent?: string | null;

  exclusions?: string | null;

};

export type CreatedGovernancePackage = {

  package_id: string;

  package_version: number;

  created_at: string;

};

export type CreateGovernanceDelegationInput = {

  delegation_id: string;

  package_id: string;

  package_version: number;

  authorization_state: string;

  authorization_timestamp?: string | null;

  delegated_by: string;

};

export type CreatedGovernanceDelegation = {

  delegation_id: string;

  package_id: string;

  package_version: number;

  authorization_state: string;

  authorization_timestamp: string;

  delegated_by: string;

  created_at: string;

};

export type CreateGovernanceValidationResultInput = {

  validation_result_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_status: string;

  governance_findings?: string | null;

  operational_requirements?: string | null;

  capability_requirements?: string | null;

  escalations?: string | null;

  validation_timestamp?: string | null;

};

export type CreatedGovernanceValidationResult = {

  validation_result_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_status: string;

  validation_timestamp: string;

  created_at: string;

};

const sqlite = new Database("db/main.db");

sqlite.pragma("foreign_keys = ON");

const requiredPackageTextFields = [

  "package_id",

  "requested_outcome",

  "scope",

  "containment",

  "constraints",

  "success_criteria",

] as const;

const requiredDelegationTextFields = [

  "delegation_id",

  "package_id",

  "authorization_state",

  "delegated_by",

] as const;

const requiredValidationTextFields = [

  "validation_result_id",

  "package_id",

  "delegation_id",

  "validation_status",

] as const;

function requirePackageText(

  input: CreateGovernancePackageInput,

  field: (typeof requiredPackageTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required governance Package field: ${field}`);

  }

  return value;

}

function requireDelegationText(

  input: CreateGovernanceDelegationInput,

  field: (typeof requiredDelegationTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required governance Delegation field: ${field}`);

  }

  return value;

}

function requireValidationText(

  input: CreateGovernanceValidationResultInput,

  field: (typeof requiredValidationTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required governance Validation field: ${field}`);

  }

  return value;

}

function requirePackageVersion(value: unknown, artifact: "Package" | "Delegation" | "Validation"): number {

  if (!Number.isInteger(value) || Number(value) < 1) {

    throw new Error(`Missing required governance ${artifact} field: package_version`);

  }

  return Number(value);

}

function optionalText(value: string | null | undefined): string | null {

  if (value === undefined || value === null) {

    return null;

  }

  return String(value);

}

function optionalTimestamp(

  value: string | null | undefined,

  artifact: "Delegation" | "Validation",

  field: "authorization_timestamp" | "validation_timestamp",

): string {

  if (value === undefined || value === null) {

    return new Date().toISOString();

  }

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required governance ${artifact} field: ${field}`);

  }

  return value;

}

export function createGovernancePackage(input: CreateGovernancePackageInput): CreatedGovernancePackage {

  const package_id = requirePackageText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version, "Package");

  const requested_outcome = requirePackageText(input, "requested_outcome");

  const scope = requirePackageText(input, "scope");

  const containment = requirePackageText(input, "containment");

  const constraints = requirePackageText(input, "constraints");

  const success_criteria = requirePackageText(input, "success_criteria");

  const created_at = new Date().toISOString();

  sqlite.prepare(`

    INSERT INTO governance_packages (

      package_id,

      package_version,

      requested_outcome,

      scope,

      containment,

      constraints,

      success_criteria,

      context,

      style_presentation_intent,

      exclusions,

      created_at

    ) VALUES (

      @package_id,

      @package_version,

      @requested_outcome,

      @scope,

      @containment,

      @constraints,

      @success_criteria,

      @context,

      @style_presentation_intent,

      @exclusions,

      @created_at

    )

  `).run({

    package_id,

    package_version,

    requested_outcome,

    scope,

    containment,

    constraints,

    success_criteria,

    context: optionalText(input.context),

    style_presentation_intent: optionalText(input.style_presentation_intent),

    exclusions: optionalText(input.exclusions),

    created_at,

  });

  return {

    package_id,

    package_version,

    created_at,

  };

}

export function createGovernanceDelegation(

  input: CreateGovernanceDelegationInput,

): CreatedGovernanceDelegation {

  const delegation_id = requireDelegationText(input, "delegation_id");

  const package_id = requireDelegationText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version, "Delegation");

  const authorization_state = requireDelegationText(input, "authorization_state");

  const authorization_timestamp = optionalTimestamp(input.authorization_timestamp, "Delegation", "authorization_timestamp");

  const delegated_by = requireDelegationText(input, "delegated_by");

  const created_at = new Date().toISOString();

  sqlite.prepare(`

    INSERT INTO governance_delegations (

      delegation_id,

      package_id,

      package_version,

      authorization_state,

      authorization_timestamp,

      delegated_by,

      created_at

    ) VALUES (

      @delegation_id,

      @package_id,

      @package_version,

      @authorization_state,

      @authorization_timestamp,

      @delegated_by,

      @created_at

    )

  `).run({

    delegation_id,

    package_id,

    package_version,

    authorization_state,

    authorization_timestamp,

    delegated_by,

    created_at,

  });

  return {

    delegation_id,

    package_id,

    package_version,

    authorization_state,

    authorization_timestamp,

    delegated_by,

    created_at,

  };

}

export function createGovernanceValidationResult(

  input: CreateGovernanceValidationResultInput,

): CreatedGovernanceValidationResult {

  const validation_result_id = requireValidationText(input, "validation_result_id");

  const package_id = requireValidationText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version, "Validation");

  const delegation_id = requireValidationText(input, "delegation_id");

  const validation_status = requireValidationText(input, "validation_status");

  const validation_timestamp = optionalTimestamp(input.validation_timestamp, "Validation", "validation_timestamp");

  const created_at = new Date().toISOString();

  sqlite.prepare(`

    INSERT INTO governance_validation_results (

      validation_result_id,

      package_id,

      package_version,

      delegation_id,

      validation_status,

      governance_findings,

      operational_requirements,

      capability_requirements,

      escalations,

      validation_timestamp,

      created_at

    ) VALUES (

      @validation_result_id,

      @package_id,

      @package_version,

      @delegation_id,

      @validation_status,

      @governance_findings,

      @operational_requirements,

      @capability_requirements,

      @escalations,

      @validation_timestamp,

      @created_at

    )

  `).run({

    validation_result_id,

    package_id,

    package_version,

    delegation_id,

    validation_status,

    governance_findings: optionalText(input.governance_findings),

    operational_requirements: optionalText(input.operational_requirements),

    capability_requirements: optionalText(input.capability_requirements),

    escalations: optionalText(input.escalations),

    validation_timestamp,

    created_at,

  });

  return {

    validation_result_id,

    package_id,

    package_version,

    delegation_id,

    validation_status,

    validation_timestamp,

    created_at,

  };

}

