import {
  executeGovernedLocalCommit,
} from "./cade-governed-commit-adapter";
import {
  executeGovernedRemotePush,
} from "./cade-governed-push-adapter";

type ExecutionEffects = {
  evaluateApproval: (input: {
    envelope: any;
    governance: any;
    approval: any;
    localCommitResult?: any;
  }) => any;
  executeCommit: typeof executeGovernedLocalCommit;
  executePush: typeof executeGovernedRemotePush;
};

export type ProductionExecutionRequest = {
  envelope: any;
  governance: any;
  approval: any;
  executionId: string;
  commitRequested: boolean;
  pushRequested: boolean;
  commitMessage?: string;
  localCommitResult?: any;
};

function requireNonEmptyString(
  value: unknown,
  message: string,
): asserts value is string {
  if (
    typeof value !== "string" ||
    value.trim().length === 0
  ) {
    throw new Error(message);
  }
}

export function executeProductionExecutionEntryPoint(
  request: ProductionExecutionRequest,
  effects: ExecutionEffects,
) {
  requireNonEmptyString(
    request.executionId,
    "production execution entry point requires execution_id",
  );

  if (request.pushRequested && !request.commitRequested) {
    if (
      !request.localCommitResult ||
      typeof request.localCommitResult !== "object"
    ) {
      throw new Error(
        "production execution entry point requires persisted local commit proof when push is requested without a new commit",
      );
    }

    const pushGate = effects.evaluateApproval({
      envelope: request.envelope,
      governance: request.governance,
      approval: request.approval,
      localCommitResult: request.localCommitResult,
    });

    if (
      pushGate?.ok !== true ||
      pushGate
        ?.version_control_authorization
        ?.commit_authorized !== true ||
      pushGate
        ?.version_control_authorization
        ?.push_authorized !== true
    ) {
      throw new Error(
        "production execution entry point requires separately proven push authority",
      );
    }

    const pushResult = effects.executePush({
      envelope: request.envelope,
      approvalGate: pushGate,
      executionId: request.executionId,
    });

    return {
      status: "ok",
      execution_id: request.executionId,
      commit_requested: false,
      push_requested: true,
      commit_result: request.localCommitResult,
      push_result: pushResult,
    };
  }

  const initialGate = effects.evaluateApproval({
    envelope: request.envelope,
    governance: request.governance,
    approval: request.approval,
  });

  if (initialGate?.ok !== true) {
    throw new Error(
      "production execution entry point requires successful approval gate",
    );
  }

  if (!request.commitRequested) {
    return {
      status: "ok",
      execution_id: request.executionId,
      commit_requested: false,
      push_requested: false,
      commit_result: null,
      push_result: null,
    };
  }

  if (
    initialGate
      ?.version_control_authorization
      ?.commit_authorized !== true
  ) {
    throw new Error(
      "production execution entry point requires commit authority",
    );
  }

  if (
    initialGate
      ?.version_control_authorization
      ?.push_authorized === true
  ) {
    throw new Error(
      "production execution entry point refuses initial push authority",
    );
  }

  requireNonEmptyString(
    request.commitMessage,
    "production execution entry point requires commit_message",
  );

  const commitResult = effects.executeCommit({
    envelope: request.envelope,
    approvalGate: initialGate,
    executionId: request.executionId,
    commitMessage: request.commitMessage,
  });

  if (!request.pushRequested) {
    return {
      status: "ok",
      execution_id: request.executionId,
      commit_requested: true,
      push_requested: false,
      commit_result: commitResult,
      push_result: null,
    };
  }

  const pushGate = effects.evaluateApproval({
    envelope: request.envelope,
    governance: request.governance,
    approval: request.approval,
    localCommitResult: commitResult,
  });

  if (
    pushGate?.ok !== true ||
    pushGate
      ?.version_control_authorization
      ?.commit_authorized !== true ||
    pushGate
      ?.version_control_authorization
      ?.push_authorized !== true
  ) {
    throw new Error(
      "production execution entry point requires separately proven push authority",
    );
  }

  const pushResult = effects.executePush({
    envelope: request.envelope,
    approvalGate: pushGate,
    executionId: request.executionId,
  });

  return {
    status: "ok",
    execution_id: request.executionId,
    commit_requested: true,
    push_requested: true,
    commit_result: commitResult,
    push_result: pushResult,
  };
}

export const productionExecutionEffects: ExecutionEffects = {
  evaluateApproval: (() => {
    throw new Error(
      "production execution approval evaluator must be explicitly bound",
    );
  }) as ExecutionEffects["evaluateApproval"],
  executeCommit: executeGovernedLocalCommit,
  executePush: executeGovernedRemotePush,
};
