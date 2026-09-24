import {
  createGovernanceEnvelope,
  type CreatedGovernanceEnvelope,
  type CreateGovernanceEnvelopeInput,
} from "../../db/governance-runtime.js";

import {
  createGovernanceEnvelopeCreationReadLoader,
  type GovernanceEnvelopeCreationReadLoader,
} from "../../db/governance-envelope-creation-read-repository.js";

import {
  invokeProductionEnvelopeEntryPoint,
  type GovernanceEnvelopePersistenceFunction,
  type ProductionEnvelopeEntryPointInput,
  type ProductionEnvelopeEntryPointResult,
} from "./production-envelope-entry-point.js";

import {
  resolveGovernanceEnvelopeSemantics,
} from "./governance-envelope-semantics.js";

export type ProductionEnvelopeConsumerInput = Omit<
  ProductionEnvelopeEntryPointInput,
  "create_governance_envelope"
> & {
  create_governance_envelope?: GovernanceEnvelopePersistenceFunction;
};

export type ProductionEnvelopeConsumerOptions = {
  load_exact_governance_envelope_creation_read_chain?: GovernanceEnvelopeCreationReadLoader;
};

export type ProductionEnvelopeConsumerResult =
  ProductionEnvelopeEntryPointResult;

function createDefaultEnvelopePersistence(): GovernanceEnvelopePersistenceFunction {
  return (
    input: CreateGovernanceEnvelopeInput,
  ): CreatedGovernanceEnvelope => createGovernanceEnvelope(input);
}

function failedClosed(findings: string[]): ProductionEnvelopeConsumerResult {
  return {
    ok: false,
    entry_point: "production_envelope_entry_point",
    endpoint_authorized: false,
    scheduler_authorized: false,
    worker_claim_authorized: false,
    orchestration_authorized: false,
    routing_authorized: false,
    assignment_authorized: false,
    lifecycle_transition_authorized: false,
    execution_authorized: false,
    new_authority_introduced: false,
    findings,
  };
}

export function consumeProductionEnvelopeEntryPoint(
  input: ProductionEnvelopeConsumerInput,
  options: ProductionEnvelopeConsumerOptions = {},
): ProductionEnvelopeConsumerResult {
  try {
    const loadExactEnvelopeCreationReadChain =
      options.load_exact_governance_envelope_creation_read_chain ??
      createGovernanceEnvelopeCreationReadLoader();

    const readChain = loadExactEnvelopeCreationReadChain({
      validation_result_id: input.validation_result_id,
      envelope_gate_id: input.envelope_gate_id,
      delegation_id: input.delegation_id,
      package_id: input.package_id,
      package_version: input.package_version,
    });

    if (
      readChain.validation_result.validation_status.trim() !==
      "VALIDATION_PASSED"
    ) {
      throw new Error(
        "Production Envelope Consumer requires exact VALIDATION_PASSED status.",
      );
    }

    if (readChain.envelope_gate.gate_status.trim() !== "OPEN") {
      throw new Error(
        "Production Envelope Consumer requires exact OPEN Envelope Gate status.",
      );
    }

    const semantics = resolveGovernanceEnvelopeSemantics(
      readChain.validation_result,
    );

    return invokeProductionEnvelopeEntryPoint({
      envelope_id: input.envelope_id,
      package_id: input.package_id,
      package_version: input.package_version,
      delegation_id: input.delegation_id,
      validation_result_id: input.validation_result_id,
      envelope_gate_id: input.envelope_gate_id,
      validation_status:
        readChain.validation_result.validation_status.trim(),
      required_capabilities: semantics.required_capabilities,
      operational_corridor: semantics.operational_corridor,
      lifecycle_state: input.lifecycle_state,
      create_governance_envelope:
        input.create_governance_envelope ??
        createDefaultEnvelopePersistence(),
    });
  } catch (error) {
    return failedClosed([
      `Production Envelope eligibility failed closed: ${
        error instanceof Error ? error.message : String(error)
      }`,
    ]);
  }
}
