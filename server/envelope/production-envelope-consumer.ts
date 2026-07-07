
import {

  createGovernanceEnvelope,

  type CreatedGovernanceEnvelope,

  type CreateGovernanceEnvelopeInput,

} from "../../db/governance-runtime.js";

import {

  invokeProductionEnvelopeEntryPoint,

  type GovernanceEnvelopePersistenceFunction,

  type ProductionEnvelopeEntryPointInput,

  type ProductionEnvelopeEntryPointResult,

} from "./production-envelope-entry-point";

export type ProductionEnvelopeConsumerInput = Omit<

  ProductionEnvelopeEntryPointInput,

  "create_governance_envelope"

> & {

  create_governance_envelope?: GovernanceEnvelopePersistenceFunction;

};

export type ProductionEnvelopeConsumerResult = ProductionEnvelopeEntryPointResult;

function createDefaultEnvelopePersistence(): GovernanceEnvelopePersistenceFunction {

  return (input: CreateGovernanceEnvelopeInput): CreatedGovernanceEnvelope =>

    createGovernanceEnvelope(input);

}

export function consumeProductionEnvelopeEntryPoint(

  input: ProductionEnvelopeConsumerInput,

): ProductionEnvelopeConsumerResult {

  return invokeProductionEnvelopeEntryPoint({

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

    create_governance_envelope:

      input.create_governance_envelope ?? createDefaultEnvelopePersistence(),

  });

}

