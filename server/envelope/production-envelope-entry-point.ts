
import type {

  CreatedGovernanceEnvelope,

  CreateGovernanceEnvelopeInput,

} from "../../db/governance-runtime.js";

export type GovernanceEnvelopePersistenceFunction = (

  input: CreateGovernanceEnvelopeInput,

) => CreatedGovernanceEnvelope;

export type ProductionEnvelopeEntryPointInput =

  CreateGovernanceEnvelopeInput & {

    create_governance_envelope: GovernanceEnvelopePersistenceFunction;

  };

type EnvelopeAuthorityFlags = {

  endpoint_authorized: false;

  scheduler_authorized: false;

  worker_claim_authorized: false;

  orchestration_authorized: false;

  routing_authorized: false;

  assignment_authorized: false;

  lifecycle_transition_authorized: false;

  execution_authorized: false;

  new_authority_introduced: false;

};

const envelopeAuthorityFlags: EnvelopeAuthorityFlags = {

  endpoint_authorized: false,

  scheduler_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  routing_authorized: false,

  assignment_authorized: false,

  lifecycle_transition_authorized: false,

  execution_authorized: false,

  new_authority_introduced: false,

};

export type ProductionEnvelopeEntryPointResult =

  | ({

      ok: true;

      entry_point: "production_envelope_entry_point";

      envelope: CreatedGovernanceEnvelope;

      findings: string[];

    } & EnvelopeAuthorityFlags)

  | ({

      ok: false;

      entry_point: "production_envelope_entry_point";

      envelope?: never;

      findings: string[];

    } & EnvelopeAuthorityFlags);

export function invokeProductionEnvelopeEntryPoint(

  input: ProductionEnvelopeEntryPointInput,

): ProductionEnvelopeEntryPointResult {

  try {

    const created = input.create_governance_envelope({

      envelope_id: input.envelope_id,

      package_id: input.package_id,

      package_version: input.package_version,

      delegation_id: input.delegation_id,

      validation_result_id: input.validation_result_id,

      envelope_gate_id: input.envelope_gate_id,

      validation_status: input.validation_status,

      required_capabilities: input.required_capabilities,

      operational_corridor: input.operational_corridor,

      lifecycle_state: input.lifecycle_state,

    });

    return {

      ok: true,

      entry_point: "production_envelope_entry_point",

      envelope: created,

      ...envelopeAuthorityFlags,

      findings: [

        "Production Envelope Entry Point created only the canonical Governance Envelope record without scheduler, worker, orchestration, routing, assignment, lifecycle transition, execution, or new authority.",

      ],

    };

  } catch (error) {

    return {

      ok: false,

      entry_point: "production_envelope_entry_point",

      ...envelopeAuthorityFlags,

      findings: [

        `Production Envelope Entry Point failed closed: ${

          error instanceof Error ? error.message : String(error)

        }`,

      ],

    };

  }

}

