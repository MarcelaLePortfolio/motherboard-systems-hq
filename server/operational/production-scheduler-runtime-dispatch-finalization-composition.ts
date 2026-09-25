import type { ProductionSchedulerRuntimeDispatchConsumerResult } from "./production-scheduler-runtime-dispatch-consumer";
import {
  authorizeSchedulerRuntimeDispatchTransition,
  type SchedulerRuntimeDispatchAuthorizationBoundaryResult,
} from "./scheduler-runtime-dispatch-authorization-boundary";
import {
  buildSchedulerRuntimeDispatchContract,
  type SchedulerRuntimeDispatchContractResult,
} from "./scheduler-runtime-dispatch-contract";
import {
  consumeSchedulerRuntimeDispatchContractForProduction,
  type ProductionSchedulerRuntimeDispatchContractConsumerResult,
} from "./production-scheduler-runtime-dispatch-contract-consumer";
import {
  authorizeSchedulerRuntimeFinalizationTransition,
  type SchedulerRuntimeFinalizationBoundaryResult,
} from "./scheduler-runtime-finalization-boundary";
import {
  invokeSchedulerRuntimeFinalizationEntryPoint,
  type SchedulerRuntimeFinalizationEntryPointResult,
} from "./scheduler-runtime-finalization-entry-point";
import {
  consumeSchedulerRuntimeFinalizationEntryPointForProduction,
  type ProductionSchedulerRuntimeFinalizationConsumerResult,
} from "./production-scheduler-runtime-finalization-consumer";

export type ProductionSchedulerRuntimeDispatchFinalizationCompositionInput = {
  production_scheduler_runtime_dispatch_consumer: ProductionSchedulerRuntimeDispatchConsumerResult;
};

export type ProductionSchedulerRuntimeDispatchFinalizationCompositionResult = {
  scheduler_runtime_dispatch_authorization: SchedulerRuntimeDispatchAuthorizationBoundaryResult;
  scheduler_runtime_dispatch_contract: SchedulerRuntimeDispatchContractResult;
  production_scheduler_runtime_dispatch_contract_consumer: ProductionSchedulerRuntimeDispatchContractConsumerResult;
  scheduler_runtime_finalization_boundary: SchedulerRuntimeFinalizationBoundaryResult;
  scheduler_runtime_finalization_entry_point: SchedulerRuntimeFinalizationEntryPointResult;
  production_scheduler_runtime_finalization_consumer: ProductionSchedulerRuntimeFinalizationConsumerResult;
  scheduler_authorized: false;
  routing_authorized: false;
  worker_claim_authorized: false;
  orchestration_authorized: false;
  execution_authorized: false;
  new_authority_introduced: false;
};

export function composeProductionSchedulerRuntimeDispatchFinalization(
  input: ProductionSchedulerRuntimeDispatchFinalizationCompositionInput,
): ProductionSchedulerRuntimeDispatchFinalizationCompositionResult {
  const schedulerRuntimeDispatchAuthorization =
    authorizeSchedulerRuntimeDispatchTransition({
      production_scheduler_runtime_dispatch_consumer:
        input.production_scheduler_runtime_dispatch_consumer,
    });

  const schedulerRuntimeDispatchContract =
    buildSchedulerRuntimeDispatchContract({
      scheduler_runtime_dispatch_authorization:
        schedulerRuntimeDispatchAuthorization,
    });

  const productionSchedulerRuntimeDispatchContractConsumer =
    consumeSchedulerRuntimeDispatchContractForProduction({
      scheduler_runtime_dispatch_contract: schedulerRuntimeDispatchContract,
    });

  const schedulerRuntimeFinalizationBoundary =
    authorizeSchedulerRuntimeFinalizationTransition({
      production_scheduler_runtime_dispatch_contract_consumer:
        productionSchedulerRuntimeDispatchContractConsumer,
    });

  const schedulerRuntimeFinalizationEntryPoint =
    invokeSchedulerRuntimeFinalizationEntryPoint({
      scheduler_runtime_finalization_boundary:
        schedulerRuntimeFinalizationBoundary,
    });

  const productionSchedulerRuntimeFinalizationConsumer =
    consumeSchedulerRuntimeFinalizationEntryPointForProduction({
      scheduler_runtime_finalization_entry_point:
        schedulerRuntimeFinalizationEntryPoint,
    });

  return {
    scheduler_runtime_dispatch_authorization:
      schedulerRuntimeDispatchAuthorization,
    scheduler_runtime_dispatch_contract: schedulerRuntimeDispatchContract,
    production_scheduler_runtime_dispatch_contract_consumer:
      productionSchedulerRuntimeDispatchContractConsumer,
    scheduler_runtime_finalization_boundary:
      schedulerRuntimeFinalizationBoundary,
    scheduler_runtime_finalization_entry_point:
      schedulerRuntimeFinalizationEntryPoint,
    production_scheduler_runtime_finalization_consumer:
      productionSchedulerRuntimeFinalizationConsumer,
    scheduler_authorized: false,
    routing_authorized: false,
    worker_claim_authorized: false,
    orchestration_authorized: false,
    execution_authorized: false,
    new_authority_introduced: false,
  };
}
