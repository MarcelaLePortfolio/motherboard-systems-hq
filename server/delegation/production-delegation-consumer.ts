
import {

  createGovernanceDelegation,

  type CreatedGovernanceDelegation,

  type CreateGovernanceDelegationInput,

} from "../../db/governance-runtime.js";

import {

  invokeProductionDelegationEntryPoint,

  type GovernanceDelegationPersistenceFunction,

  type ProductionDelegationEntryPointInput,

  type ProductionDelegationEntryPointResult,

} from "./production-delegation-entry-point";

export type ProductionDelegationConsumerInput = Omit<

  ProductionDelegationEntryPointInput,

  "create_governance_delegation"

> & {

  create_governance_delegation?: GovernanceDelegationPersistenceFunction;

};

export type ProductionDelegationConsumerResult =

  ProductionDelegationEntryPointResult;

function createDefaultDelegationPersistence(): GovernanceDelegationPersistenceFunction {

  return (

    input: CreateGovernanceDelegationInput,

  ): CreatedGovernanceDelegation => {

    return createGovernanceDelegation(input);

  };

}

export function consumeProductionDelegationEntryPoint(

  input: ProductionDelegationConsumerInput,

): ProductionDelegationConsumerResult {

  return invokeProductionDelegationEntryPoint({

    delegation_id: input.delegation_id,

    project_id: input.project_id,

    package_id: input.package_id,

    package_version: input.package_version,

    authorization_state: input.authorization_state,

    authorization_timestamp: input.authorization_timestamp,

    delegated_by: input.delegated_by,

    create_governance_delegation:

      input.create_governance_delegation ??

      createDefaultDelegationPersistence(),

  });

}

