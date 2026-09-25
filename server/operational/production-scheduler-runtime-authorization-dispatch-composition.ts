import type { ProductionSchedulerRuntimeConsumerResult } from "./production-scheduler-runtime-consumer";
import {
  authorizeSchedulerRuntimeTransition,
  type SchedulerRuntimeAuthorizationBoundaryResult,
} from "./scheduler-runtime-authorization-boundary";
import {
  buildSchedulerRuntimeContract,
  type SchedulerRuntimeContractResult,
} from "./scheduler-runtime-contract";
import {
  consumeSchedulerRuntimeContractForProduction,
  type ProductionSchedulerRuntimeContractConsumerResult,
} from "./production-scheduler-runtime-contract-consumer";
import {
  evaluateSchedulerRuntimeDispatchBoundary,
  type SchedulerRuntimeDispatchBoundaryResult,
} from "./scheduler-runtime-dispatch-boundary";
import {
  invokeSchedulerRuntimeDispatchEntryPoint,
  type SchedulerRuntimeDispatchEntryPointResult,
} from "./scheduler-runtime-dispatch-entry-point";
import {
  consumeSchedulerRuntimeDispatchEntryPointForProduction,
  type ProductionSchedulerRuntimeDispatchConsumerResult,
} from "./production-scheduler-runtime-dispatch-consumer";

export type ProductionSchedulerRuntimeAuthorizationDispatchCompositionInput = {
  production_scheduler_runtime_consumer: ProductionSchedulerRuntimeConsumerResult;
};

export type ProductionSchedulerRuntimeAuthorizationDispatchCompositionResult = {
  scheduler_runtime_authorization: SchedulerRuntimeAuthorizationBoundaryResult;
  scheduler_runtime_contract: SchedulerRuntimeContractResult;
  production_scheduler_runtime_contract_consumer: ProductionSchedulerRuntimeContractConsumerResult;
  scheduler_runtime_dispatch_boundary: SchedulerRuntimeDispatchBoundaryResult;
  scheduler_runtime_dispatch_entry_point: SchedulerRuntimeDispatchEntryPointResult;
  production_scheduler_runtime_dispatch_consumer: ProductionSchedulerRuntimeDispatchConsumerResult;
  scheduler_authorized: false;
  routing_authorized: false;
  worker_claim_authorized: false;
  orchestration_authorized: false;
  execution_authorized: false;
  new_authority_introduced: false;
};

export function composeProductionSchedulerRuntimeAuthorizationDispatch(
  input: ProductionSchedulerRuntimeAuthorizationDispatchCompositionInput,
): ProductionSchedulerRuntimeAuthorizationDispatchCompositionResult {
  const schedulerRuntimeAuthorization = authorizeSchedulerRuntimeTransition({
    production_scheduler_runtime_consumer:
      input.production_scheduler_runtime_consumer,
  });

  const schedulerRuntimeContract = buildSchedulerRuntimeContract({
    scheduler_runtime_authorization: schedulerRuntimeAuthorization,
  });

  const productionSchedulerRuntimeContractConsumer =
    consumeSchedulerRuntimeContractForProduction({
      scheduler_runtime_contract: schedulerRuntimeContract,
    });

  const schedulerRuntimeDispatchBoundary =
    evaluateSchedulerRuntimeDispatchBoundary({
      production_scheduler_runtime_contract_consumer:
        productionSchedulerRuntimeContractConsumer,
    });

  const schedulerRuntimeDispatchEntryPoint =
    invokeSchedulerRuntimeDispatchEntryPoint({
      scheduler_runtime_dispatch_boundary: schedulerRuntimeDispatchBoundary,
    });

  const productionSchedulerRuntimeDispatchConsumer =
    consumeSchedulerRuntimeDispatchEntryPointForProduction({
      scheduler_runtime_dispatch_entry_point:
        schedulerRuntimeDispatchEntryPoint,
    });

  return {
    scheduler_runtime_authorization: schedulerRuntimeAuthorization,
    scheduler_runtime_contract: schedulerRuntimeContract,
    production_scheduler_runtime_contract_consumer:
      productionSchedulerRuntimeContractConsumer,
    scheduler_runtime_dispatch_boundary: schedulerRuntimeDispatchBoundary,
    scheduler_runtime_dispatch_entry_point: schedulerRuntimeDispatchEntryPoint,
    production_scheduler_runtime_dispatch_consumer:
      productionSchedulerRuntimeDispatchConsumer,
    scheduler_authorized: false,
    routing_authorized: false,
    worker_claim_authorized: false,
    orchestration_authorized: false,
    execution_authorized: false,
    new_authority_introduced: false,
  };
}
