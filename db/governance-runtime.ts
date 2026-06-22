
import { sqlite } from "./client";

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

const requiredTextFields = [

  "package_id",

  "requested_outcome",

  "scope",

  "containment",

  "constraints",

  "success_criteria",

] as const;

function requireText(input: CreateGovernancePackageInput, field: (typeof requiredTextFields)[number]): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required governance Package field: ${field}`);

  }

  return value;

}

function requirePackageVersion(value: unknown): number {

  if (!Number.isInteger(value) || Number(value) < 1) {

    throw new Error("Missing required governance Package field: package_version");

  }

  return Number(value);

}

function optionalText(value: string | null | undefined): string | null {

  if (value === undefined || value === null) {

    return null;

  }

  return String(value);

}

export function createGovernancePackage(input: CreateGovernancePackageInput): CreatedGovernancePackage {

  const package_id = requireText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version);

  const requested_outcome = requireText(input, "requested_outcome");

  const scope = requireText(input, "scope");

  const containment = requireText(input, "containment");

  const constraints = requireText(input, "constraints");

  const success_criteria = requireText(input, "success_criteria");

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

