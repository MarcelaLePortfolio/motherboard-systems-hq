import {
  performGovernedLocalCommit,
  type GovernedLocalCommitResult,
} from "../cade/cade-version-control-effects";
import { recordExecutionEvent } from "../cade/cade-event-wrapper";

type GovernedCommitEnvelope = {
  identity?: {
    envelope_id?: string | null;
  };
  project_target?: {
    repo_path?: string | null;
    branch?: string | null;
    expected_head?: string | null;
  };
  mutation_scope?: {
    allowed_paths?: string[];
  };
};

type GovernedCommitApproval = {
  approval_artifact?: {
    approval_id?: string | null;
  };
  version_control_authorization?: {
    commit_authorized?: boolean;
    push_authorized?: boolean;
  };
};

export function executeGovernedLocalCommit({
  envelope,
  approvalGate,
  executionId,
  commitMessage,
}: {
  envelope: GovernedCommitEnvelope;
  approvalGate: GovernedCommitApproval;
  executionId: string;
  commitMessage: string;
}): GovernedLocalCommitResult {
  if (
    approvalGate
      ?.version_control_authorization
      ?.commit_authorized !== true
  ) {
    throw new Error(
      "governed commit adapter requires commit_authorized=true",
    );
  }

  if (
    approvalGate
      ?.version_control_authorization
      ?.push_authorized === true
  ) {
    throw new Error(
      "governed commit adapter refuses push_authorized=true",
    );
  }

  const approvalId =
    approvalGate?.approval_artifact?.approval_id;

  const envelopeId =
    envelope?.identity?.envelope_id;

  const repoPath =
    envelope?.project_target?.repo_path;

  const branch =
    envelope?.project_target?.branch;

  const expectedHead =
    envelope?.project_target?.expected_head;

  const allowedPaths =
    envelope?.mutation_scope?.allowed_paths;

  if (!approvalId) {
    throw new Error(
      "governed commit adapter requires approval_id",
    );
  }

  if (!envelopeId) {
    throw new Error(
      "governed commit adapter requires envelope_id",
    );
  }

  if (!executionId) {
    throw new Error(
      "governed commit adapter requires execution_id",
    );
  }

  if (!repoPath) {
    throw new Error(
      "governed commit adapter requires repo_path",
    );
  }

  if (!branch) {
    throw new Error(
      "governed commit adapter requires branch",
    );
  }

  if (!expectedHead) {
    throw new Error(
      "governed commit adapter requires expected_head",
    );
  }

  if (
    !Array.isArray(allowedPaths) ||
    allowedPaths.length === 0
  ) {
    throw new Error(
      "governed commit adapter requires allowed_paths",
    );
  }

  if (!commitMessage) {
    throw new Error(
      "governed commit adapter requires commit_message",
    );
  }

  const result = performGovernedLocalCommit({
    repoPath,
    branch,
    expectedHead,
    allowedPaths,
    commitMessage,
    approvalId,
    envelopeId,
    executionId,
    commitAuthorized: true,
    pushAuthorized: false,
  });

  recordExecutionEvent({
    id: executionId,
    action: "commit_changes",
    input: {
      repo_path: repoPath,
      branch,
      expected_head: expectedHead,
      approval_id: approvalId,
      envelope_id: envelopeId,
      execution_id: executionId,
      commit_message: commitMessage,
    },
    output: {
      pre_head: result.preHead,
      post_head: result.postHead,
      committed_files: result.committedFiles,
      commit_message: result.commitMessage,
      remote_effect: false,
      push_effect: false,
    },
    affectedFiles: result.committedFiles,
  });

  return result;
}
