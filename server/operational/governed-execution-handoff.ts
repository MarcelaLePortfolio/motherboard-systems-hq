import { randomUUID } from "node:crypto";
import type { Database } from "better-sqlite3";

import type { SchedulerDispatchContractResult } from "./scheduler-dispatch-contract";
import type { ProductionSchedulerRuntimeFinalizationReadinessCompletionConsumerResult } from "./production-scheduler-runtime-finalization-readiness-completion-consumer";
import {
  handleGovernanceExecutionRouteRequest,
  type GovernanceExecutionRouteDependencies,
} from "../routes/governance-execution-route";
import {
  productionGovernanceExecutionDependencies,
} from "../execution/production-governance-execution-composition";

export type GovernedExecutionEffectIntent =
  | { kind: "no_effect" }
  | { kind: "commit"; commit_message: string }
  | { kind: "commit_and_push"; commit_message: string }
  | { kind: "push"; prior_commit_execution_id: string };

export type GovernedExecutionHandoffInput = {
  scheduler_dispatch_contract: SchedulerDispatchContractResult;
  scheduler_runtime_finalization_readiness_completion:
    ProductionSchedulerRuntimeFinalizationReadinessCompletionConsumerResult;
  effect_intent: GovernedExecutionEffectIntent;
};

export type GovernedExecutionHandoffResult =
  | {
      ok: true;
      handoff: "governed_execution_handoff";
      governed_execution_handoff_completed: true;
      envelope_id: string;
      package_id: string;
      package_version: number;
      approval_id: string;
      execution_id: string;
      effect_intent: GovernedExecutionEffectIntent["kind"];
      commit_requested: boolean;
      push_requested: boolean;
      scheduler_authorized: false;
      routing_authorized: false;
      worker_claim_authorized: false;
      orchestration_authorized: false;
      execution_authorized: false;
      new_authority_introduced: false;
      execution_result: ReturnType<typeof handleGovernanceExecutionRouteRequest>;
      findings: string[];
    }
  | {
      ok: false;
      handoff: "governed_execution_handoff";
      governed_execution_handoff_completed: false;
      scheduler_authorized: false;
      routing_authorized: false;
      worker_claim_authorized: false;
      orchestration_authorized: false;
      execution_authorized: false;
      new_authority_introduced: false;
      findings: string[];
    };

type GovernedExecutionHandoffDependencies = {
  db?: Database;
  governance_execution_dependencies?: GovernanceExecutionRouteDependencies;
  create_execution_id?: () => string;
  invoke_governance_execution?: typeof handleGovernanceExecutionRouteRequest;
};

type DurableGovernanceIdentity = {
  approval_id: string;
  envelope_id: string;
  package_id: string;
  package_version: number;
};

function requireNonEmptyText(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`Governed execution handoff requires ${field}.`);
  }

  return value.trim();
}

function compileEffectIntent(intent: GovernedExecutionEffectIntent) {
  switch (intent.kind) {
    case "no_effect":
      return {
        commit_requested: false,
        push_requested: false,
      };

    case "commit":
      return {
        commit_requested: true,
        push_requested: false,
        commit_message: requireNonEmptyText(
          intent.commit_message,
          "commit_message for commit intent",
        ),
      };

    case "commit_and_push":
      return {
        commit_requested: true,
        push_requested: true,
        commit_message: requireNonEmptyText(
          intent.commit_message,
          "commit_message for commit_and_push intent",
        ),
      };

    case "push":
      return {
        commit_requested: false,
        push_requested: true,
        prior_commit_execution_id: requireNonEmptyText(
          intent.prior_commit_execution_id,
          "prior_commit_execution_id for push intent",
        ),
      };
  }
}

function resolveApprovalIdentityForEnvelope(
  db: Database,
  envelopeId: string,
): DurableGovernanceIdentity {
  const rows = db
    .prepare(`
      SELECT
        approval_id,
        envelope_id,
        package_id,
        package_version
      FROM governance_execution_scopes
      WHERE envelope_id = ?
      LIMIT 2
    `)
    .all(envelopeId) as DurableGovernanceIdentity[];

  if (rows.length !== 1) {
    throw new Error(
      `Governed execution handoff requires exactly one durable execution scope for envelope: ${envelopeId}`,
    );
  }

  return rows[0];
}

export function handoffSchedulerReadinessToGovernedExecution(
  input: GovernedExecutionHandoffInput,
  dependencies: GovernedExecutionHandoffDependencies = {},
): GovernedExecutionHandoffResult {
  const dispatch = input.scheduler_dispatch_contract;
  const completion =
    input.scheduler_runtime_finalization_readiness_completion;

  if (
    !dispatch.ok ||
    !dispatch.scheduler_dispatch_ready ||
    !completion.ok ||
    !completion.scheduler_runtime_finalization_readiness_completion_consumed
  ) {
    return {
      ok: false,
      handoff: "governed_execution_handoff",
      governed_execution_handoff_completed: false,
      scheduler_authorized: false,
      routing_authorized: false,
      worker_claim_authorized: false,
      orchestration_authorized: false,
      execution_authorized: false,
      new_authority_introduced: false,
      findings: [
        "Governed execution handoff failed closed because scheduler dispatch identity or terminal runtime readiness completion was not established.",
      ],
    };
  }

  try {
    const governanceDependencies =
      dependencies.governance_execution_dependencies ??
      productionGovernanceExecutionDependencies;

    const db = dependencies.db ?? governanceDependencies.db;

    const durableIdentity =
      resolveApprovalIdentityForEnvelope(
        db,
        dispatch.envelope_id,
      );

    if (
      durableIdentity.envelope_id !== dispatch.envelope_id ||
      durableIdentity.package_id !== dispatch.package_id ||
      durableIdentity.package_version !== dispatch.package_version
    ) {
      throw new Error(
        "Governed execution handoff durable scope lineage does not match scheduler dispatch lineage.",
      );
    }

    const effectRequest =
      compileEffectIntent(input.effect_intent);

    const executionId =
      dependencies.create_execution_id?.() ??
      `execution-${randomUUID()}`;

    const invokeGovernanceExecution =
      dependencies.invoke_governance_execution ??
      handleGovernanceExecutionRouteRequest;

    const executionResult =
      invokeGovernanceExecution(
        {
          approval_id: durableIdentity.approval_id,
          envelope_id: durableIdentity.envelope_id,
          execution_id: executionId,
          commit_requested: effectRequest.commit_requested,
          push_requested: effectRequest.push_requested,
          ...(effectRequest.commit_message
            ? { commit_message: effectRequest.commit_message }
            : {}),
          ...(effectRequest.prior_commit_execution_id
            ? {
                prior_commit_execution_id:
                  effectRequest.prior_commit_execution_id,
              }
            : {}),
        },
        governanceDependencies,
      );

    if (executionResult.ok !== true) {
      return {
        ok: false,
        handoff: "governed_execution_handoff",
        governed_execution_handoff_completed: false,
        scheduler_authorized: false,
        routing_authorized: false,
        worker_claim_authorized: false,
        orchestration_authorized: false,
        execution_authorized: false,
        new_authority_introduced: false,
        findings: [
          "Governed execution handoff reached the existing governance execution boundary, which failed closed.",
          ...(
            Array.isArray((executionResult as any).findings)
              ? (executionResult as any).findings
              : []
          ),
        ],
      };
    }

    return {
      ok: true,
      handoff: "governed_execution_handoff",
      governed_execution_handoff_completed: true,
      envelope_id: durableIdentity.envelope_id,
      package_id: durableIdentity.package_id,
      package_version: durableIdentity.package_version,
      approval_id: durableIdentity.approval_id,
      execution_id: executionId,
      effect_intent: input.effect_intent.kind,
      commit_requested: effectRequest.commit_requested,
      push_requested: effectRequest.push_requested,
      scheduler_authorized: false,
      routing_authorized: false,
      worker_claim_authorized: false,
      orchestration_authorized: false,
      execution_authorized: false,
      new_authority_introduced: false,
      execution_result: executionResult,
      findings: [
        "Scheduler readiness was handed to the existing governed execution boundary without creating scheduler, routing, worker-claim, orchestration, execution, commit, push, or new authority.",
        "Explicit effect intent was transported to the existing governance execution route and did not itself confer effect authority.",
      ],
    };
  } catch (error) {
    return {
      ok: false,
      handoff: "governed_execution_handoff",
      governed_execution_handoff_completed: false,
      scheduler_authorized: false,
      routing_authorized: false,
      worker_claim_authorized: false,
      orchestration_authorized: false,
      execution_authorized: false,
      new_authority_introduced: false,
      findings: [
        error instanceof Error
          ? error.message
          : "Governed execution handoff failed closed.",
      ],
    };
  }
}
