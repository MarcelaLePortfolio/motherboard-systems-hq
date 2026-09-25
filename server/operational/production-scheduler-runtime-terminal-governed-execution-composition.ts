import type { SchedulerDispatchContractResult } from "./scheduler-dispatch-contract";
import type { ProductionSchedulerRuntimeFinalizationReadinessCompletionConsumerResult } from "./production-scheduler-runtime-finalization-readiness-completion-consumer";
import {
  authorizeSchedulerRuntimeFinalizationReadinessCompletionTransition,
  type SchedulerRuntimeFinalizationReadinessCompletionAuthorizationBoundaryResult,
} from "./scheduler-runtime-finalization-readiness-completion-authorization-boundary";
import {
  buildSchedulerRuntimeFinalizationReadinessCompletionContract,
  type SchedulerRuntimeFinalizationReadinessCompletionContractResult,
} from "./scheduler-runtime-finalization-readiness-completion-contract";
import {
  consumeSchedulerRuntimeFinalizationReadinessCompletionContractForProduction,
  type ProductionSchedulerRuntimeFinalizationReadinessCompletionContractConsumerResult,
} from "./production-scheduler-runtime-finalization-readiness-completion-contract-consumer";
import {
  handoffSchedulerReadinessToGovernedExecution,
  type GovernedExecutionEffectIntent,
  type GovernedExecutionHandoffResult,
} from "./governed-execution-handoff";

export type ProductionSchedulerRuntimeTerminalGovernedExecutionCompositionInput = {
  scheduler_dispatch_contract: SchedulerDispatchContractResult;
  production_scheduler_runtime_finalization_readiness_completion_consumer:
    ProductionSchedulerRuntimeFinalizationReadinessCompletionConsumerResult;
  effect_intent: GovernedExecutionEffectIntent;
};

export type ProductionSchedulerRuntimeTerminalGovernedExecutionCompositionResult = {
  scheduler_runtime_finalization_readiness_completion_authorization:
    SchedulerRuntimeFinalizationReadinessCompletionAuthorizationBoundaryResult;
  scheduler_runtime_finalization_readiness_completion_contract:
    SchedulerRuntimeFinalizationReadinessCompletionContractResult;
  production_scheduler_runtime_finalization_readiness_completion_contract_consumer:
    ProductionSchedulerRuntimeFinalizationReadinessCompletionContractConsumerResult;
  governed_execution_handoff: GovernedExecutionHandoffResult | null;
  scheduler_authorized: false;
  routing_authorized: false;
  worker_claim_authorized: false;
  orchestration_authorized: false;
  execution_authorized: false;
  new_authority_introduced: false;
};

export function composeProductionSchedulerRuntimeTerminalGovernedExecution(
  input: ProductionSchedulerRuntimeTerminalGovernedExecutionCompositionInput,
): ProductionSchedulerRuntimeTerminalGovernedExecutionCompositionResult {
  const authorization =
    authorizeSchedulerRuntimeFinalizationReadinessCompletionTransition({
      production_scheduler_runtime_finalization_readiness_completion_consumer:
        input.production_scheduler_runtime_finalization_readiness_completion_consumer,
    });

  const contract =
    buildSchedulerRuntimeFinalizationReadinessCompletionContract({
      scheduler_runtime_finalization_readiness_completion_authorization:
        authorization,
    });

  const contractConsumer =
    consumeSchedulerRuntimeFinalizationReadinessCompletionContractForProduction({
      scheduler_runtime_finalization_readiness_completion_contract: contract,
    });

  const governedExecutionHandoff =
    contractConsumer.ok &&
    contractConsumer.scheduler_runtime_finalization_readiness_completion_contract_consumed
      ? handoffSchedulerReadinessToGovernedExecution({
          scheduler_dispatch_contract: input.scheduler_dispatch_contract,
          scheduler_runtime_finalization_readiness_completion:
            input.production_scheduler_runtime_finalization_readiness_completion_consumer,
          effect_intent: input.effect_intent,
        })
      : null;

  return {
    scheduler_runtime_finalization_readiness_completion_authorization:
      authorization,
    scheduler_runtime_finalization_readiness_completion_contract: contract,
    production_scheduler_runtime_finalization_readiness_completion_contract_consumer:
      contractConsumer,
    governed_execution_handoff: governedExecutionHandoff,
    scheduler_authorized: false,
    routing_authorized: false,
    worker_claim_authorized: false,
    orchestration_authorized: false,
    execution_authorized: false,
    new_authority_introduced: false,
  };
}
