import {
  performGovernedRemotePush,
  type GovernedRemotePushResult,
} from "../cade/cade-version-control-effects";
import { recordExecutionEvent } from "../cade/cade-event-wrapper";
import {
  observeGovernedRepositoryState,
} from "./governed-repository-state-observer";

export function executeGovernedRemotePush({
  envelope,
  approvalGate,
  executionId,
}: {
  envelope: any;
  approvalGate: any;
  executionId: string;
}): GovernedRemotePushResult {
  const vc =
    approvalGate
      ?.version_control_authorization;

  if (vc?.commit_authorized !== true) {
    throw new Error(
      "governed push adapter requires commit_authorized=true",
    );
  }

  if (vc?.push_authorized !== true) {
    throw new Error(
      "governed push adapter requires push_authorized=true",
    );
  }

  const repoPath =
    envelope?.project_target?.repo_path;

  const branch =
    envelope?.project_target?.branch;

  const expectedLocalHead =
    approvalGate?.expected_push_head;

  const approvalId =
    approvalGate
      ?.approval_artifact
      ?.approval_id;

  const envelopeId =
    envelope?.identity?.envelope_id;

  if (!repoPath) {
    throw new Error(
      "governed push adapter requires repo_path",
    );
  }

  if (!branch) {
    throw new Error(
      "governed push adapter requires branch",
    );
  }

  const observed = observeGovernedRepositoryState({
    repoPath,
  });

  if (observed.branch !== branch) {
    throw new Error(
      "governed push adapter observed branch does not match durable execution scope branch",
    );
  }

  const result =
    performGovernedRemotePush({
      repoPath,
      branch,
      remote: observed.remote_name,
      expectedLocalHead,
      expectedRemoteUrl: observed.remote_push_url,
      approvalId,
      envelopeId,
      executionId,
      commitAuthorized: true,
      pushAuthorized: true,
    });

  recordExecutionEvent({
    id: executionId,
    action: "push_changes",
    input: {
      repo_path: repoPath,
      branch,
      remote: observed.remote_name,
      remote_url:
        result.remoteUrl,
      expected_local_head:
        expectedLocalHead,
      approval_id: approvalId,
      envelope_id: envelopeId,
      execution_id: executionId,
    },
    output: {
      pre_remote_head:
        result.preRemoteHead,
      post_remote_head:
        result.postRemoteHead,
      local_head:
        result.localHead,
      remote_effect: true,
      push_effect: true,
      force_effect: false,
    },
    affectedFiles: [],
  });

  return result;
}
