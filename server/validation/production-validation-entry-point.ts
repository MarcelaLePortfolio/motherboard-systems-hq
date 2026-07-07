
import type {

  CreatedGovernanceValidationResult,

  CreateGovernanceValidationResultInput,

} from "../../db/governance-runtime.js";

export type GovernanceValidationPersistenceFunction = (

  input: CreateGovernanceValidationResultInput,

) => CreatedGovernanceValidationResult;

export type ProductionValidationEntryPointInput =

  CreateGovernanceValidationResultInput & {

    create_governance_validation_result: GovernanceValidationPersistenceFunction;

  };

type ValidationAuthorityFlags = {

  endpoint_authorized: false;

  scheduler_authorized: false;

  worker_claim_authorized: false;

  orchestration_authorized: false;

  routing_authorized: false;

  assignment_authorized: false;

  lifecycle_transition_authorized: false;

  execution_authorized: false;

  downstream_governance_authorized: false;

  new_authority_introduced: false;

};

const validationAuthorityFlags: ValidationAuthorityFlags = {

  endpoint_authorized: false,

  scheduler_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  routing_authorized: false,

  assignment_authorized: false,

  lifecycle_transition_authorized: false,

  execution_authorized: false,

  downstream_governance_authorized: false,

  new_authority_introduced: false,

};

export type ProductionValidationEntryPointResult =

  | ({

      ok: true;

      entry_point: "production_validation_entry_point";

      validation: CreatedGovernanceValidationResult;

      findings: string[];

    } & ValidationAuthorityFlags)

  | ({

      ok: false;

      entry_point: "production_validation_entry_point";

      validation?: never;

      findings: string[];

    } & ValidationAuthorityFlags);

export function invokeProductionValidationEntryPoint(

  input: ProductionValidationEntryPointInput,

): ProductionValidationEntryPointResult {

  try {

    const created = input.create_governance_validation_result({

      validation_result_id: input.validation_result_id,

      package_id: input.package_id,

      package_version: input.package_version,

      delegation_id: input.delegation_id,

      validation_status: input.validation_status,

      governance_findings: input.governance_findings,

      operational_requirements: input.operational_requirements,

      capability_requirements: input.capability_requirements,

      escalations: input.escalations,

      validation_timestamp: input.validation_timestamp,

    });

    return {

      ok: true,

      entry_point: "production_validation_entry_point",

      validation: created,

      ...validationAuthorityFlags,

      findings: [

        "Production Validation Entry Point created only the canonical Governance Validation Result without scheduler, worker, orchestration, routing, assignment, lifecycle transition, execution, downstream governance, or new authority.",

      ],

    };

  } catch (error) {

    return {

      ok: false,

      entry_point: "production_validation_entry_point",

      ...validationAuthorityFlags,

      findings: [

        `Production Validation Entry Point failed closed: ${

          error instanceof Error ? error.message : String(error)

        }`,

      ],

    };

  }

}

