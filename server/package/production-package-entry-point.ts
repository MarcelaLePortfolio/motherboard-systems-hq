
import type {

  CreatedGovernancePackage,

  CreateGovernancePackageInput,

} from "../../db/governance-runtime.ts";

export type GovernancePackagePersistenceFunction = (

  input: CreateGovernancePackageInput,

) => CreatedGovernancePackage;

export type ProductionPackageEntryPointInput = CreateGovernancePackageInput & {

  create_governance_package: GovernancePackagePersistenceFunction;

};

type PackageAuthorityFlags = {

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

const packageAuthorityFlags: PackageAuthorityFlags = {

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

export type ProductionPackageEntryPointResult =

  | ({

      ok: true;

      entry_point: "production_package_entry_point";

      package: CreatedGovernancePackage;

      findings: string[];

    } & PackageAuthorityFlags)

  | ({

      ok: false;

      entry_point: "production_package_entry_point";

      package?: never;

      findings: string[];

    } & PackageAuthorityFlags);

export function invokeProductionPackageEntryPoint(

  input: ProductionPackageEntryPointInput,

): ProductionPackageEntryPointResult {

  try {

    const created = input.create_governance_package({

      package_id: input.package_id,

      package_version: input.package_version,

      requested_outcome: input.requested_outcome,

      scope: input.scope,

      containment: input.containment,

      constraints: input.constraints,

      success_criteria: input.success_criteria,

      context: input.context,

      style_presentation_intent: input.style_presentation_intent,

      exclusions: input.exclusions,

    });

    return {

      ok: true,

      entry_point: "production_package_entry_point",

      package: created,

      ...packageAuthorityFlags,

      findings: [

        "Production Package Entry Point created only the canonical Package meaning artifact without endpoint, scheduler, worker, orchestration, routing, assignment, lifecycle transition, execution, downstream governance, or new authority.",

      ],

    };

  } catch (error) {

    return {

      ok: false,

      entry_point: "production_package_entry_point",

      ...packageAuthorityFlags,

      findings: [

        `Production Package Entry Point failed closed: ${

          error instanceof Error ? error.message : String(error)

        }`,

      ],

    };

  }

}

