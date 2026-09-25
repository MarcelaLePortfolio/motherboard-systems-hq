import type { ProductionSchedulerExecutionConsumerResult } from "./production-scheduler-execution-consumer";
import {
  evaluateSchedulerRuntimeBoundary,
  type SchedulerRuntimeBoundaryResult,
} from "./scheduler-runtime-boundary";
import {
  invokeSchedulerRuntimeEntryPoint,
  type SchedulerRuntimeEntryPointResult,
} from "./scheduler-runtime-entry-point";
import {
  consumeSchedulerRuntimeEntryPointForProduction,
  type ProductionSchedulerRuntimeConsumerResult,
} from "./production-scheduler-runtime-consumer";

export type ProductionSchedulerRuntimeCompositionInput = {
  production_scheduler_execution_consumer: ProductionSchedulerExecutionConsumerResult;
};

export type ProductionSchedulerRuntimeCompositionResult = {
  scheduler_runtime_boundary: SchedulerRuntimeBoundaryResult;
  scheduler_runtime_entry_point: SchedulerRuntimeEntryPointResult;
  production_scheduler_runtime_consumer: ProductionSchedulerRuntimeConsumerResult;
  scheduler_authorized: false;
  routing_authorized: false;
  worker_claim_authorized: false;
  orchestration_authorized: false;
  execution_authorized: false;
  new_authority_introduced: false;
};

export function composeProductionSchedulerRuntime(
  input: ProductionSchedulerRuntimeCompositionInput,
): ProductionSchedulerRuntimeCompositionResult {
  const schedulerRuntimeBoundary = evaluateSchedulerRuntimeBoundary({
    production_scheduler_execution_consumer:
      input.production_scheduler_execution_consumer,
  });

  const schedulerRuntimeEntryPoint = invokeSchedulerRuntimeEntryPoint({
    scheduler_runtime_boundary: schedulerRuntimeBoundary,
  });

  const productionSchedulerRuntimeConsumer =
    consumeSchedulerRuntimeEntryPointForProduction({
      scheduler_runtime_entry_point: schedulerRuntimeEntryPoint,
    });

  return {
    scheduler_runtime_boundary: schedulerRuntimeBoundary,
    scheduler_runtime_entry_point: schedulerRuntimeEntryPoint,
    production_scheduler_runtime_consumer: productionSchedulerRuntimeConsumer,
    scheduler_authorized: false,
    routing_authorized: false,
    worker_claim_authorized: false,
    orchestration_authorized: false,
    execution_authorized: false,
    new_authority_introduced: false,
  };
}
