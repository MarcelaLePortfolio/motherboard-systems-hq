
import type {

  CreatedGovernanceDelegation,

  CreateGovernanceDelegationInput,

} from "../../db/governance-runtime.js";

export type GovernanceDelegationPersistenceFunction = (

  input: CreateGovernanceDelegationInput,

) => CreatedGovernanceDelegation;

export type ProductionDelegationEntryPointInput = CreateGovernanceDelegationInput & {

  create_governance_delegation: GovernanceDelegationPersistenceFunction;

};

type DelegationAuthorityFlags = {

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

const delegationAuthorityFlags: DelegationAuthorityFlags = {

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

export type ProductionDelegationEntryPointResult =

  | ({

      ok: true;

      entry_point: "production_delegation_entry_point";

      delegation: CreatedGovernanceDelegation;

      findings: string[];

    } & DelegationAuthorityFlags)

  | ({

      ok: false;

      entry_point: "production_delegation_entry_point";

      delegation?: never;

      findings: string[];

    } & DelegationAuthorityFlags);

export function invokeProductionDelegationEntryPoint(

  input: ProductionDelegationEntryPointInput,

): ProductionDelegationEntryPointResult {

  try {

    const created = input.create_governance_delegation({

      delegation_id: input.delegation_id,

      package_id: input.package_id,

      package_version: input.package_version,

      authorization_state: input.authorization_state,

      authorization_timestamp: input.authorization_timestamp,

      delegated_by: input.delegated_by,

    });

    return {

      ok: true,

      entry_point: "production_delegation_entry_point",

      delegation: created,

      ...delegationAuthorityFlags,

      findings: [

        "Production Delegation Entry Point created only the canonical Delegation record without scheduler, worker, orchestration, routing, assignment, lifecycle transition, execution, downstream governance, or new authority.",

      ],

    };

  } catch (error) {

    return {

      ok: false,

      entry_point: "production_delegation_entry_point",

      ...delegationAuthorityFlags,

      findings: [

        `Production Delegation Entry Point failed closed: ${

          error instanceof Error ? error.message : String(error)

        }`,

      ],

    };

  }

}

