import {
  createGovernanceValidationResult,
  type CreatedGovernanceValidationResult,
  type CreateGovernanceValidationResultInput,
} from "../../db/governance-runtime.js";

import {
  createGovernanceValidationDelegationLoader,
  type GovernanceValidationDelegationLoader,
} from "../../db/governance-validation-read-repository.js";

import {
  assertValidationEligible,
} from "../../db/governance-lifecycle-enforcement.js";

import {
  invokeProductionValidationEntryPoint,
  type GovernanceValidationPersistenceFunction,
  type ProductionValidationEntryPointInput,
  type ProductionValidationEntryPointResult,
} from "./production-validation-entry-point";

export type ProductionValidationConsumerInput = Omit<
  ProductionValidationEntryPointInput,
  "create_governance_validation_result"
> & {
  create_governance_validation_result?: GovernanceValidationPersistenceFunction;
  load_exact_governance_delegation?: GovernanceValidationDelegationLoader;
};

export type ProductionValidationConsumerResult =
  ProductionValidationEntryPointResult;

function createDefaultValidationPersistence(): GovernanceValidationPersistenceFunction {
  return (
    input: CreateGovernanceValidationResultInput,
  ): CreatedGovernanceValidationResult => {
    return createGovernanceValidationResult(input);
  };
}

function failedClosed(findings: string[]): ProductionValidationConsumerResult {
  return {
    ok: false,
    entry_point: "production_validation_entry_point",
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
    findings,
  };
}

export function consumeProductionValidationEntryPoint(
  input: ProductionValidationConsumerInput,
): ProductionValidationConsumerResult {
  try {
    const loadExactGovernanceDelegation =
      input.load_exact_governance_delegation ??
      createGovernanceValidationDelegationLoader();

    const delegation = loadExactGovernanceDelegation({
      delegation_id: input.delegation_id,
      package_id: input.package_id,
      package_version: input.package_version,
    });

    assertValidationEligible({ delegation });
  } catch (error) {
    return failedClosed([
      `Production Validation eligibility failed closed: ${
        error instanceof Error ? error.message : String(error)
      }`,
    ]);
  }

  return invokeProductionValidationEntryPoint({
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
    create_governance_validation_result:
      input.create_governance_validation_result ??
      createDefaultValidationPersistence(),
  });
}
