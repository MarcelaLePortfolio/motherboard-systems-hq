import {
  evaluateSchedulerReadinessBoundary,
  type SchedulerReadinessBoundaryResult,
} from "./scheduler-readiness-boundary";
import {
  invokeSchedulerEntryPoint,
  type SchedulerEntryPointResult,
} from "./scheduler-entry-point";
import {
  consumeSchedulerEntryPointForProduction,
  type ProductionSchedulerConsumerResult,
} from "./production-scheduler-consumer";
import {
  authorizeSchedulerTransition,
  type SchedulerAuthorizationBoundaryResult,
} from "./scheduler-authorization-boundary";
import {
  buildSchedulerDispatchContract,
  type SchedulerDispatchContractResult,
} from "./scheduler-dispatch-contract";
import {
  consumeSchedulerDispatchContractForProduction,
  type ProductionSchedulerDispatchConsumerResult,
} from "./production-scheduler-dispatch-consumer";
import {
  evaluateSchedulerExecutionReadinessBoundary,
  type SchedulerExecutionReadinessBoundaryResult,
} from "./scheduler-execution-readiness-boundary";
import {
  invokeSchedulerExecutionEntryPoint,
  type SchedulerExecutionEntryPointResult,
} from "./scheduler-execution-entry-point";
import {
  consumeSchedulerExecutionEntryPointForProduction,
  type ProductionSchedulerExecutionConsumerResult,
} from "./production-scheduler-execution-consumer";
import type { ProductionLifecycleConsumerResult } from "../lifecycle/production-lifecycle-consumer";

export type ProductionLifecycleSchedulerCompositionInput = {
  production_lifecycle_consumer: ProductionLifecycleConsumerResult;
};

export type ProductionLifecycleSchedulerCompositionResult = {
  scheduler_readiness: SchedulerReadinessBoundaryResult;
  scheduler_entry_point: SchedulerEntryPointResult;
  production_scheduler_consumer: ProductionSchedulerConsumerResult;
  scheduler_authorization: SchedulerAuthorizationBoundaryResult;
  scheduler_dispatch_contract: SchedulerDispatchContractResult;
  production_scheduler_dispatch_consumer: ProductionSchedulerDispatchConsumerResult;
  scheduler_execution_readiness: SchedulerExecutionReadinessBoundaryResult;
  scheduler_execution_entry_point: SchedulerExecutionEntryPointResult;
  production_scheduler_execution_consumer: ProductionSchedulerExecutionConsumerResult;
  scheduler_authorized: false;
  routing_authorized: false;
  worker_claim_authorized: false;
  orchestration_authorized: false;
  execution_authorized: false;
  new_authority_introduced: false;
};

export function composeProductionLifecycleScheduler(
  input: ProductionLifecycleSchedulerCompositionInput,
): ProductionLifecycleSchedulerCompositionResult {
  const lifecycle = input.production_lifecycle_consumer;

  if (!lifecycle.ok) {
    const failedReadiness = evaluateSchedulerReadinessBoundary({
      operational_consumption: lifecycle.operational_consumption ?? {
        ok: false,
        consumer: "production_operational_consumer",
        downstream_consumption_ready: false,
        scheduler_authorized: false,
        routing_authorized: false,
        worker_claim_authorized: false,
        orchestration_authorized: false,
        execution_authorized: false,
        new_authority_introduced: false,
        findings: ["Lifecycle consumption was unavailable."],
      },
    });

    const failedEntryPoint = invokeSchedulerEntryPoint({
      scheduler_readiness: failedReadiness,
    });

    const failedSchedulerConsumer =
      consumeSchedulerEntryPointForProduction({
        scheduler_entry_point: failedEntryPoint,
      });

    const failedAuthorization = authorizeSchedulerTransition({
      production_scheduler_consumer: failedSchedulerConsumer,
    });

    const failedDispatch = buildSchedulerDispatchContract({
      scheduler_authorization: failedAuthorization,
      operational_intake: lifecycle.operational_intake ?? ({} as never),
    });

    const failedDispatchConsumer =
      consumeSchedulerDispatchContractForProduction({
        scheduler_dispatch_contract: failedDispatch,
      });

    const failedExecutionReadiness =
      evaluateSchedulerExecutionReadinessBoundary({
        production_scheduler_dispatch_consumer: failedDispatchConsumer,
      });

    const failedExecutionEntryPoint = invokeSchedulerExecutionEntryPoint({
      scheduler_execution_readiness: failedExecutionReadiness,
    });

    const failedExecutionConsumer =
      consumeSchedulerExecutionEntryPointForProduction({
        scheduler_execution_entry_point: failedExecutionEntryPoint,
      });

    return {
      scheduler_readiness: failedReadiness,
      scheduler_entry_point: failedEntryPoint,
      production_scheduler_consumer: failedSchedulerConsumer,
      scheduler_authorization: failedAuthorization,
      scheduler_dispatch_contract: failedDispatch,
      production_scheduler_dispatch_consumer: failedDispatchConsumer,
      scheduler_execution_readiness: failedExecutionReadiness,
      scheduler_execution_entry_point: failedExecutionEntryPoint,
      production_scheduler_execution_consumer: failedExecutionConsumer,
      scheduler_authorized: false,
      routing_authorized: false,
      worker_claim_authorized: false,
      orchestration_authorized: false,
      execution_authorized: false,
      new_authority_introduced: false,
    };
  }

  const schedulerReadiness = evaluateSchedulerReadinessBoundary({
    operational_consumption: lifecycle.operational_consumption,
  });

  const schedulerEntryPoint = invokeSchedulerEntryPoint({
    scheduler_readiness: schedulerReadiness,
  });

  const productionSchedulerConsumer =
    consumeSchedulerEntryPointForProduction({
      scheduler_entry_point: schedulerEntryPoint,
    });

  const schedulerAuthorization = authorizeSchedulerTransition({
    production_scheduler_consumer: productionSchedulerConsumer,
  });

  const schedulerDispatchContract = buildSchedulerDispatchContract({
    scheduler_authorization: schedulerAuthorization,
    operational_intake: lifecycle.operational_intake,
  });

  const productionSchedulerDispatchConsumer =
    consumeSchedulerDispatchContractForProduction({
      scheduler_dispatch_contract: schedulerDispatchContract,
    });

  const schedulerExecutionReadiness =
    evaluateSchedulerExecutionReadinessBoundary({
      production_scheduler_dispatch_consumer:
        productionSchedulerDispatchConsumer,
    });

  const schedulerExecutionEntryPoint = invokeSchedulerExecutionEntryPoint({
    scheduler_execution_readiness: schedulerExecutionReadiness,
  });

  const productionSchedulerExecutionConsumer =
    consumeSchedulerExecutionEntryPointForProduction({
      scheduler_execution_entry_point: schedulerExecutionEntryPoint,
    });

  return {
    scheduler_readiness: schedulerReadiness,
    scheduler_entry_point: schedulerEntryPoint,
    production_scheduler_consumer: productionSchedulerConsumer,
    scheduler_authorization: schedulerAuthorization,
    scheduler_dispatch_contract: schedulerDispatchContract,
    production_scheduler_dispatch_consumer:
      productionSchedulerDispatchConsumer,
    scheduler_execution_readiness: schedulerExecutionReadiness,
    scheduler_execution_entry_point: schedulerExecutionEntryPoint,
    production_scheduler_execution_consumer:
      productionSchedulerExecutionConsumer,
    scheduler_authorized: false,
    routing_authorized: false,
    worker_claim_authorized: false,
    orchestration_authorized: false,
    execution_authorized: false,
    new_authority_introduced: false,
  };
}
