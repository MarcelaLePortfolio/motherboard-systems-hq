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
  invokeProductionValidationEntryPoint,
  type GovernanceValidationPersistenceFunction,
  type ProductionValidationEntryPointResult,
} from "./production-validation-entry-point.js";

import {
  loadGovernanceValidationEvidence,
} from "./governance-validation-evidence-loader.js";

import {
  analyzeGovernanceValidationSemantics,
  type GovernanceValidationSemanticResult,
} from "./governance-validation-semantic-adapter.js";

export type GovernanceValidationSemanticAnalysisFunction = (
  evidence: Parameters<typeof analyzeGovernanceValidationSemantics>[0],
) => Promise<GovernanceValidationSemanticResult>;

export type ProductionValidationConsumerInput = {
  validation_result_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
  validation_timestamp?: string | null;
  create_governance_validation_result?: GovernanceValidationPersistenceFunction;
  load_exact_governance_delegation?: GovernanceValidationDelegationLoader;
  analyze_governance_validation_semantics?: GovernanceValidationSemanticAnalysisFunction;
  database_path?: string;
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

export async function consumeProductionValidationEntryPoint(
  input: ProductionValidationConsumerInput,
): Promise<ProductionValidationConsumerResult> {
  try {
    const loadExactGovernanceDelegation =
      input.load_exact_governance_delegation ??
      createGovernanceValidationDelegationLoader(input.database_path);

    const evidence = loadGovernanceValidationEvidence(
      {
        delegation_id: input.delegation_id,
        package_id: input.package_id,
        package_version: input.package_version,
      },
      {
        database_path: input.database_path,
        load_exact_governance_delegation: loadExactGovernanceDelegation,
      },
    );

    const analyzeSemantics =
      input.analyze_governance_validation_semantics ??
      analyzeGovernanceValidationSemantics;

    const semanticResult = await analyzeSemantics(evidence);

    return invokeProductionValidationEntryPoint({
      validation_result_id: input.validation_result_id,
      package_id: input.package_id,
      package_version: input.package_version,
      delegation_id: input.delegation_id,
      validation_status: semanticResult.validation_status,
      governance_findings: semanticResult.governance_findings,
      operational_requirements: semanticResult.operational_requirements,
      capability_requirements: semanticResult.capability_requirements,
      escalations: semanticResult.escalations,
      validation_timestamp: input.validation_timestamp,
      create_governance_validation_result:
        input.create_governance_validation_result ??
        createDefaultValidationPersistence(),
    });
  } catch (error) {
    return failedClosed([
      `Production Validation semantic evaluation failed closed: ${
        error instanceof Error ? error.message : String(error)
      }`,
    ]);
  }
}
