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

export type GovernedExecutionHandoffInput = {
  scheduler_dispatch_contract: SchedulerDispatchContractResult;
  scheduler_runtime_finalization_readiness_completion:
    ProductionSchedulerRuntimeFinalizationReadinessCompletionConsumerResult;
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
      commit_requested: false;
      push_requested: false;
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
};

function resolveApprovalIdentityForEnvelope(
  db: Database,
  envelopeId: string,
): {
  approval_id: string;
  envelope_id: string;
  package_id: string;
  package_version: number;
} {
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
    .all(envelopeId) as Array<{
      approval_id: string;
      envelope_id: string;
      package_id: string;
      package_version: number;
    }>;

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

    const db =
      dependencies.db ??
      governanceDependencies.db;

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

    const executionId =
      dependencies.create_execution_id?.() ??
      `execution-${randomUUID()}`;

    const executionResult =
      handleGovernanceExecutionRouteRequest(
        {
          approval_id: durableIdentity.approval_id,
          envelope_id: durableIdentity.envelope_id,
          execution_id: executionId,
          commit_requested: false,
          push_requested: false,
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
      commit_requested: false,
      push_requested: false,
      scheduler_authorized: false,
      routing_authorized: false,
      worker_claim_authorized: false,
      orchestration_authorized: false,
      execution_authorized: false,
      new_authority_introduced: false,
      execution_result: executionResult,
      findings: [
        "Scheduler readiness was handed to the existing governed execution boundary without creating scheduler, routing, worker-claim, orchestration, execution, commit, push, or new authority.",
        "The handoff requested no repository effect; commit and push effect selection remain outside Corridor 2.",
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
