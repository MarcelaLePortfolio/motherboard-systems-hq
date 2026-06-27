
import {

  createGovernanceEnvelopeGate,

  type CreatedGovernanceEnvelopeGate,

  type CreateGovernanceEnvelopeGateInput,

} from "../../db/governance-runtime.ts";

import {

  invokeProductionEnvelopeGateEntryPoint,

  type GovernanceEnvelopeGatePersistenceFunction,

  type ProductionEnvelopeGateEntryPointInput,

  type ProductionEnvelopeGateEntryPointResult,

} from "./production-envelope-gate-entry-point.ts";

export type ProductionEnvelopeGateConsumerInput = Omit<

  ProductionEnvelopeGateEntryPointInput,

  "create_governance_envelope_gate"

> & {

  create_governance_envelope_gate?: GovernanceEnvelopeGatePersistenceFunction;

};

export type ProductionEnvelopeGateConsumerResult =

  ProductionEnvelopeGateEntryPointResult;

function createDefaultEnvelopeGatePersistence(): GovernanceEnvelopeGatePersistenceFunction {

  return (

    input: CreateGovernanceEnvelopeGateInput,

  ): CreatedGovernanceEnvelopeGate => createGovernanceEnvelopeGate(input);

}

export function consumeProductionEnvelopeGateEntryPoint(

  input: ProductionEnvelopeGateConsumerInput,

): ProductionEnvelopeGateConsumerResult {

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

