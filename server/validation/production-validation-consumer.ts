
import {

  createGovernanceValidationResult,

  type CreatedGovernanceValidationResult,

  type CreateGovernanceValidationResultInput,

} from "../../db/governance-runtime.ts";

import {

  invokeProductionValidationEntryPoint,

  type GovernanceValidationPersistenceFunction,

  type ProductionValidationEntryPointInput,

  type ProductionValidationEntryPointResult,

} from "./production-validation-entry-point.ts";

export type ProductionValidationConsumerInput = Omit<

  ProductionValidationEntryPointInput,

  "create_governance_validation_result"

> & {

  create_governance_validation_result?: GovernanceValidationPersistenceFunction;

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

export function consumeProductionValidationEntryPoint(

  input: ProductionValidationConsumerInput,

): ProductionValidationConsumerResult {

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

