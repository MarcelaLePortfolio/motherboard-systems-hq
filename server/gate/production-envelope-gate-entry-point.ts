
import type {

  CreatedGovernanceEnvelopeGate,

  CreateGovernanceEnvelopeGateInput,

} from "../../db/governance-runtime.js";

export type GovernanceEnvelopeGatePersistenceFunction = (

  input: CreateGovernanceEnvelopeGateInput,

) => CreatedGovernanceEnvelopeGate;

export type ProductionEnvelopeGateEntryPointInput =

  CreateGovernanceEnvelopeGateInput & {

    create_governance_envelope_gate: GovernanceEnvelopeGatePersistenceFunction;

  };

type EnvelopeGateAuthorityFlags = {

  endpoint_authorized: false;

  scheduler_authorized: false;

  worker_claim_authorized: false;

  orchestration_authorized: false;

  routing_authorized: false;

  assignment_authorized: false;

  lifecycle_transition_authorized: false;

  execution_authorized: false;

  envelope_creation_authorized: false;

  new_authority_introduced: false;

};

const envelopeGateAuthorityFlags: EnvelopeGateAuthorityFlags = {

  endpoint_authorized: false,

  scheduler_authorized: false,

  worker_claim_authorized: false,

  orchestration_authorized: false,

  routing_authorized: false,

  assignment_authorized: false,

  lifecycle_transition_authorized: false,

  execution_authorized: false,

  envelope_creation_authorized: false,

  new_authority_introduced: false,

};

export type ProductionEnvelopeGateEntryPointResult =

  | ({

      ok: true;

      entry_point: "production_envelope_gate_entry_point";

      envelope_gate: CreatedGovernanceEnvelopeGate;

      findings: string[];

    } & EnvelopeGateAuthorityFlags)

  | ({

      ok: false;

      entry_point: "production_envelope_gate_entry_point";

      envelope_gate?: never;

      findings: string[];

    } & EnvelopeGateAuthorityFlags);

export function invokeProductionEnvelopeGateEntryPoint(

  input: ProductionEnvelopeGateEntryPointInput,

): ProductionEnvelopeGateEntryPointResult {

  try {

    const created = input.create_governance_envelope_gate({

      envelope_gate_id: input.envelope_gate_id,

      package_id: input.package_id,

      package_version: input.package_version,

      delegation_id: input.delegation_id,

      validation_result_id: input.validation_result_id,

      gate_status: input.gate_status,

      gate_reason: input.gate_reason,

      gate_decision_timestamp: input.gate_decision_timestamp,

    });

    return {

      ok: true,

      entry_point: "production_envelope_gate_entry_point",

      envelope_gate: created,

      ...envelopeGateAuthorityFlags,

      findings: [

        "Production Envelope Gate Entry Point created only the canonical Envelope Gate record without scheduler, worker, orchestration, routing, assignment, lifecycle transition, execution, Envelope creation, or new authority.",

      ],

    };

  } catch (error) {

    return {

      ok: false,

      entry_point: "production_envelope_gate_entry_point",

      ...envelopeGateAuthorityFlags,

      findings: [

        `Production Envelope Gate Entry Point failed closed: ${

          error instanceof Error ? error.message : String(error)

        }`,

      ],

    };

  }

}

