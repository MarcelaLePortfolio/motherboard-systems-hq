#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="094b6c66c330358ff3b5db6d458d431c44888aee"

if [[ "$(git rev-parse HEAD)" != "$EXPECTED_HEAD" ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

TARGET="server/execution/production-execution-entry-point.ts"
TEST="server/execution/production-execution-entry-point.test.ts"

cat > "$TARGET" <<'TS'
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
  expectedRemoteUrl?: string;
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
    throw new Error(
      "production execution entry point requires commit when push is requested",
    );
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

  requireNonEmptyString(
    request.expectedRemoteUrl,
    "production execution entry point requires expected_remote_url",
  );

  const pushResult = effects.executePush({
    envelope: request.envelope,
    approvalGate: pushGate,
    executionId: request.executionId,
    expectedRemoteUrl: request.expectedRemoteUrl,
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
TS

cat > "$TEST" <<'TS'
import assert from "node:assert/strict";
import test from "node:test";

import {
  executeProductionExecutionEntryPoint,
} from "./production-execution-entry-point";

const envelope = {
  identity: {
    envelope_id: "env-c6",
    package_id: "pkg-c6",
    package_version: 1,
    delegation_id: "del-c6",
    validation_result_id: "val-c6",
    envelope_gate_id: "gate-c6",
  },
  delegation_authorization: {
    state: "delegated",
  },
  project_target: {
    repo_path: "/tmp/not-used",
    branch: "feature/test",
    expected_head: "abc123",
  },
  mutation_scope: {
    allowed_paths: ["server/example.ts"],
  },
};

const approval = {
  approval_id: "approval-c6",
  status: "approved",
};

const governance = {
  ok: true,
};

test(
  "commit-only execution composes existing authority and effect boundaries",
  () => {
    const calls: string[] = [];

    const result =
      executeProductionExecutionEntryPoint(
        {
          envelope,
          governance,
          approval,
          executionId: "exec-c6",
          commitRequested: true,
          pushRequested: false,
          commitMessage: "bounded test commit",
        },
        {
          evaluateApproval() {
            calls.push("gate");
            return {
              ok: true,
              approval_artifact: approval,
              version_control_authorization: {
                commit_authorized: true,
                push_authorized: false,
              },
            };
          },
          executeCommit() {
            calls.push("commit");
            return {
              status: "ok",
              preHead: "abc123",
              postHead: "def456",
              branch: "feature/test",
              approvalId: "approval-c6",
              envelopeId: "env-c6",
              executionId: "exec-c6",
              remoteEffect: false,
              pushEffect: false,
            } as any;
          },
          executePush() {
            throw new Error("push must not execute");
          },
        },
      );

    assert.deepEqual(calls, ["gate", "commit"]);
    assert.equal(result.status, "ok");
    assert.equal(result.push_result, null);
  },
);

test(
  "push requires correlated commit followed by separately proven push authority",
  () => {
    const calls: string[] = [];

    const result =
      executeProductionExecutionEntryPoint(
        {
          envelope,
          governance,
          approval,
          executionId: "exec-c6",
          commitRequested: true,
          pushRequested: true,
          commitMessage: "bounded test commit",
          expectedRemoteUrl:
            "https://example.invalid/repository.git",
        },
        {
          evaluateApproval({ localCommitResult }) {
            if (!localCommitResult) {
              calls.push("initial-gate");
              return {
                ok: true,
                approval_artifact: approval,
                version_control_authorization: {
                  commit_authorized: true,
                  push_authorized: false,
                },
              };
            }

            calls.push("push-gate");
            return {
              ok: true,
              approval_artifact: approval,
              expected_push_head: "def456",
              version_control_authorization: {
                commit_authorized: true,
                push_authorized: true,
                remote: "origin",
                branch: "feature/test",
              },
            };
          },
          executeCommit() {
            calls.push("commit");
            return {
              status: "ok",
              preHead: "abc123",
              postHead: "def456",
              branch: "feature/test",
              approvalId: "approval-c6",
              envelopeId: "env-c6",
              executionId: "exec-c6",
              remoteEffect: false,
              pushEffect: false,
            } as any;
          },
          executePush() {
            calls.push("push");
            return {
              status: "ok",
            } as any;
          },
        },
      );

    assert.deepEqual(
      calls,
      ["initial-gate", "commit", "push-gate", "push"],
    );
    assert.equal(result.status, "ok");
  },
);

test(
  "initial push authority is rejected before any effect",
  () => {
    let commitCalled = false;

    assert.throws(
      () =>
        executeProductionExecutionEntryPoint(
          {
            envelope,
            governance,
            approval,
            executionId: "exec-c6",
            commitRequested: true,
            pushRequested: true,
            commitMessage: "bounded test commit",
            expectedRemoteUrl:
              "https://example.invalid/repository.git",
          },
          {
            evaluateApproval() {
              return {
                ok: true,
                version_control_authorization: {
                  commit_authorized: true,
                  push_authorized: true,
                },
              };
            },
            executeCommit() {
              commitCalled = true;
              return {} as any;
            },
            executePush() {
              return {} as any;
            },
          },
        ),
      /refuses initial push authority/,
    );

    assert.equal(commitCalled, false);
  },
);

test(
  "push cannot execute without commit request",
  () => {
    assert.throws(
      () =>
        executeProductionExecutionEntryPoint(
          {
            envelope,
            governance,
            approval,
            executionId: "exec-c6",
            commitRequested: false,
            pushRequested: true,
          },
          {
            evaluateApproval() {
              throw new Error("gate must not run");
            },
            executeCommit() {
              throw new Error("commit must not run");
            },
            executePush() {
              throw new Error("push must not run");
            },
          },
        ),
      /requires commit when push is requested/,
    );
  },
);
TS

echo "=== BOUNDED DIFF ==="
git diff -- "$TARGET" "$TEST"

echo
echo "=== TYPESCRIPT CHECK ==="
npm run check

echo
echo "=== TARGETED TEST ==="
node --import tsx --test "$TEST"

echo
echo "=== SCOPE CHECK ==="
CHANGED="$(git diff --name-only)"
printf '%s\n' "$CHANGED"

UNEXPECTED="$(
  printf '%s\n' "$CHANGED" |
  grep -v '^server/execution/production-execution-entry-point\.ts$' |
  grep -v '^server/execution/production-execution-entry-point\.test\.ts$' || true
)"

if [[ -n "$UNEXPECTED" ]]; then
  echo "STOP=UNEXPECTED_TRACKED_CHANGE"
  printf '%s\n' "$UNEXPECTED"
  exit 1
fi

git add "$TARGET" "$TEST"
git diff --cached --check
git commit -m "Add bounded production execution entry point"
git push

echo
echo "=== POST-IMPLEMENTATION STATE ==="
echo "CORRIDOR_6=SELF_IMPROVEMENT_EXECUTION_ACTIVATION_CLOSURE"
echo "BOUNDED_EXECUTION_ENTRY_POINT=IMPLEMENTED"
echo "FAIL_CLOSED_TESTS=IMPLEMENTED"
echo "REAL_COMMIT_PERFORMED=NO"
echo "REAL_PUSH_PERFORMED=NO"
echo "ROUTE_MOUNT_CHANGE=NO"
echo "PRODUCTION_REACHABILITY_CHANGE=NO"
echo "CORRIDOR_6_STATUS=PENDING_IMPLEMENTATION_VERIFICATION"
echo "NEXT_ACTION=VERIFY_BOUNDED_ENTRY_POINT_BEFORE_ANY_REACHABILITY_DECISION"
echo "HEAD=$(git rev-parse HEAD)"
git status --short
