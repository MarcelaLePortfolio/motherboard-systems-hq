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
  "push without a new commit requires persisted local commit proof",
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
      /requires persisted local commit proof when push is requested without a new commit/,
    );
  },
);

test(
  "persisted successful local commit proof can enter separately authorized push without another commit",
  () => {
    const calls: string[] = [];

    const localCommitResult = {
      status: "ok",
      preHead: "abc123",
      postHead: "def456",
      branch: "feature/test",
      approvalId: "approval-c6",
      envelopeId: "env-c6",
      executionId: "prior-commit-exec-c6",
      remoteEffect: false,
      pushEffect: false,
    };

    const result =
      executeProductionExecutionEntryPoint(
        {
          envelope,
          governance,
          approval,
          executionId: "push-only-exec-c6",
          commitRequested: false,
          pushRequested: true,
          localCommitResult,
        },
        {
          evaluateApproval({ localCommitResult: supplied }) {
            calls.push("push-gate");
            assert.equal(supplied, localCommitResult);

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
            throw new Error("commit must not run");
          },
          executePush() {
            calls.push("push");
            return {
              status: "ok",
            } as any;
          },
        },
      );

    assert.deepEqual(calls, ["push-gate", "push"]);
    assert.equal(result.status, "ok");
    assert.equal(result.commit_requested, false);
    assert.equal(result.push_requested, true);
    assert.equal(result.commit_result, localCommitResult);
  },
);
