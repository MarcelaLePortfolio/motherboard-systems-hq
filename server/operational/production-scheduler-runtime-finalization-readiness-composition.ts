import type { ProductionSchedulerRuntimeFinalizationConsumerResult } from "./production-scheduler-runtime-finalization-consumer";
import {
  authorizeSchedulerRuntimeFinalizationTransition,
  type SchedulerRuntimeFinalizationAuthorizationBoundaryResult,
} from "./scheduler-runtime-finalization-authorization-boundary";
import {
  buildSchedulerRuntimeFinalizationContract,
  type SchedulerRuntimeFinalizationContractResult,
} from "./scheduler-runtime-finalization-contract";
import {
  consumeSchedulerRuntimeFinalizationContractForProduction,
  type ProductionSchedulerRuntimeFinalizationContractConsumerResult,
} from "./production-scheduler-runtime-finalization-contract-consumer";
import {
  evaluateSchedulerRuntimeFinalizationReadinessBoundary,
  type SchedulerRuntimeFinalizationReadinessBoundaryResult,
} from "./scheduler-runtime-finalization-readiness-boundary";
import {
  invokeSchedulerRuntimeFinalizationReadinessEntryPoint,
  type SchedulerRuntimeFinalizationReadinessEntryPointResult,
} from "./scheduler-runtime-finalization-readiness-entry-point";
import {
  consumeSchedulerRuntimeFinalizationReadinessEntryPointForProduction,
  type ProductionSchedulerRuntimeFinalizationReadinessConsumerResult,
} from "./production-scheduler-runtime-finalization-readiness-consumer";

export type ProductionSchedulerRuntimeFinalizationReadinessCompositionInput = {
  production_scheduler_runtime_finalization_consumer: ProductionSchedulerRuntimeFinalizationConsumerResult;
};

export type ProductionSchedulerRuntimeFinalizationReadinessCompositionResult = {
  scheduler_runtime_finalization_authorization: SchedulerRuntimeFinalizationAuthorizationBoundaryResult;
  scheduler_runtime_finalization_contract: SchedulerRuntimeFinalizationContractResult;
  production_scheduler_runtime_finalization_contract_consumer: ProductionSchedulerRuntimeFinalizationContractConsumerResult;
  scheduler_runtime_finalization_readiness_boundary: SchedulerRuntimeFinalizationReadinessBoundaryResult;
  scheduler_runtime_finalization_readiness_entry_point: SchedulerRuntimeFinalizationReadinessEntryPointResult;
  production_scheduler_runtime_finalization_readiness_consumer: ProductionSchedulerRuntimeFinalizationReadinessConsumerResult;
  scheduler_authorized: false;
  routing_authorized: false;
  worker_claim_authorized: false;
  orchestration_authorized: false;
  execution_authorized: false;
  new_authority_introduced: false;
};

export function composeProductionSchedulerRuntimeFinalizationReadiness(
  input: ProductionSchedulerRuntimeFinalizationReadinessCompositionInput,
): ProductionSchedulerRuntimeFinalizationReadinessCompositionResult {
  const authorization = authorizeSchedulerRuntimeFinalizationTransition({
    production_scheduler_runtime_finalization_consumer:
      input.production_scheduler_runtime_finalization_consumer,
  });

  const contract = buildSchedulerRuntimeFinalizationContract({
    scheduler_runtime_finalization_authorization: authorization,
  });

  const contractConsumer =
    consumeSchedulerRuntimeFinalizationContractForProduction({
      scheduler_runtime_finalization_contract: contract,
    });

  const readinessBoundary =
    evaluateSchedulerRuntimeFinalizationReadinessBoundary({
      production_scheduler_runtime_finalization_contract_consumer:
        contractConsumer,
    });

  const readinessEntryPoint =
    invokeSchedulerRuntimeFinalizationReadinessEntryPoint({
      scheduler_runtime_finalization_readiness_boundary: readinessBoundary,
    });

  const readinessConsumer =
    consumeSchedulerRuntimeFinalizationReadinessEntryPointForProduction({
      scheduler_runtime_finalization_readiness_entry_point:
        readinessEntryPoint,
    });

  return {
    scheduler_runtime_finalization_authorization: authorization,
    scheduler_runtime_finalization_contract: contract,
    production_scheduler_runtime_finalization_contract_consumer:
      contractConsumer,
    scheduler_runtime_finalization_readiness_boundary: readinessBoundary,
    scheduler_runtime_finalization_readiness_entry_point: readinessEntryPoint,
    production_scheduler_runtime_finalization_readiness_consumer:
      readinessConsumer,
    scheduler_authorized: false,
    routing_authorized: false,
    worker_claim_authorized: false,
    orchestration_authorized: false,
    execution_authorized: false,
    new_authority_introduced: false,
  };
}
