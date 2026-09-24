
import {

  createGovernanceEnvelopeGate,

  type CreatedGovernanceEnvelopeGate,

  type CreateGovernanceEnvelopeGateInput,

} from "../../db/governance-runtime.js";

import {
  createGovernanceEnvelopeGateValidationLoader,
  type GovernanceEnvelopeGateValidationLoader,
} from "../../db/governance-envelope-gate-validation-read-repository.js";

import {
  assertEnvelopeCreationEligible,
} from "../../db/governance-lifecycle-enforcement.js";

import {

  invokeProductionEnvelopeGateEntryPoint,

  type GovernanceEnvelopeGatePersistenceFunction,

  type ProductionEnvelopeGateEntryPointInput,

  type ProductionEnvelopeGateEntryPointResult,

} from "./production-envelope-gate-entry-point";

export type ProductionEnvelopeGateConsumerInput = Omit<

  ProductionEnvelopeGateEntryPointInput,

  "create_governance_envelope_gate"

> & {

  create_governance_envelope_gate?: GovernanceEnvelopeGatePersistenceFunction;

  load_exact_governance_validation_result?: GovernanceEnvelopeGateValidationLoader;

};

export type ProductionEnvelopeGateConsumerResult =

  ProductionEnvelopeGateEntryPointResult;

function createDefaultEnvelopeGatePersistence(): GovernanceEnvelopeGatePersistenceFunction {

  return (

    input: CreateGovernanceEnvelopeGateInput,

  ): CreatedGovernanceEnvelopeGate => createGovernanceEnvelopeGate(input);

}


function failedClosed(findings: string[]): ProductionEnvelopeGateConsumerResult {

  return {

    ok: false,

    entry_point: "production_envelope_gate_entry_point",

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

    findings,

  };

}

export function consumeProductionEnvelopeGateEntryPoint(

  input: ProductionEnvelopeGateConsumerInput,

): ProductionEnvelopeGateConsumerResult {

  try {

    const loadValidationResult =

      input.load_exact_governance_validation_result ??

      createGovernanceEnvelopeGateValidationLoader();

    const validationResult = loadValidationResult({

      validation_result_id: input.validation_result_id,

      delegation_id: input.delegation_id,

      package_id: input.package_id,

      package_version: input.package_version,

    });

    assertEnvelopeCreationEligible({

      validationResult,

      envelopeGate: { gate_status: "OPEN" },

      envelope: {

        required_capabilities: "envelope_gate_validation_only",

        operational_corridor: "envelope_gate_validation_only",

      },

    });

  } catch (error) {

    return failedClosed([

      `Production Envelope Gate eligibility failed closed: ${

        error instanceof Error ? error.message : String(error)

      }`,

    ]);

  }

  return invokeProductionEnvelopeGateEntryPoint({

    envelope_gate_id: input.envelope_gate_id,

    package_id: input.package_id,

    package_version: input.package_version,

    delegation_id: input.delegation_id,

    validation_result_id: input.validation_result_id,

    gate_status: input.gate_status,

    gate_reason: input.gate_reason,

    gate_decision_timestamp: input.gate_decision_timestamp,

    create_governance_envelope_gate:

      input.create_governance_envelope_gate ??

      createDefaultEnvelopeGatePersistence(),

  });

}

