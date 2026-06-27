
import {

  createGovernancePackage,

  type CreatedGovernancePackage,

  type CreateGovernancePackageInput,

} from "../../db/governance-runtime.ts";

import {

  invokeProductionPackageEntryPoint,

  type GovernancePackagePersistenceFunction,

  type ProductionPackageEntryPointInput,

  type ProductionPackageEntryPointResult,

} from "./production-package-entry-point.ts";

export type ProductionPackageConsumerInput = Omit<

  ProductionPackageEntryPointInput,

  "create_governance_package"

> & {

  create_governance_package?: GovernancePackagePersistenceFunction;

};

export type ProductionPackageConsumerResult = ProductionPackageEntryPointResult;

function createDefaultPackagePersistence(): GovernancePackagePersistenceFunction {

  return (input: CreateGovernancePackageInput): CreatedGovernancePackage => {

    return createGovernancePackage(input);

  };

}

export function consumeProductionPackageEntryPoint(

  input: ProductionPackageConsumerInput,

): ProductionPackageConsumerResult {

  return invokeProductionPackageEntryPoint({

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

    create_governance_package:

      input.create_governance_package ?? createDefaultPackagePersistence(),

  });

}

