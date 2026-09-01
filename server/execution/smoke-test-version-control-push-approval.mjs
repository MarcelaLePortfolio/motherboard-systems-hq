import assert from "node:assert/strict";

import { createExecutionEnvelope } from "../contracts/execution-envelope.v1.mjs";
import { buildApprovalArtifact } from "./build-approval-artifact.mjs";
import { evaluateExecutionApproval } from "./execution-approval-gate.mjs";
import { validateGovernedExecutionEnvelope } from "./governance-validator.mjs";

const head = "a".repeat(40);

function buildEnvelope() {
  return createExecutionEnvelope({
    identity: {
      envelope_id:
        "env-push-approval-smoke",
      intent_id:
        "intent-push-approval-smoke",
    },
    intent: {
      raw_user_intent:
        "validate push approval",
      normalized_intent:
        "validate push approval",
      intent_type: "inspect",
      intent_evidence: [
        "user_authorization",
      ],
      confidence_score: 1,
    },
    project_target: {
      project_name:
        "Motherboard Systems",
      repo_path: process.cwd(),
      branch:
        "feature/support-source-references-runtime",
      expected_head: head,
      workspace_type:
        "motherboard_systems",
    },
    mutation_scope: {
      scope_type: "file",
      allowed_paths: [
        "docs/contracts/",
      ],
      forbidden_paths: [
        "secrets/",
        ".env",
      ],
      scope_constraints:
        "push approval smoke only",
    },
    execution_plan: {
      summary:
        "validate push approval",
      steps: [
        {
          step_id: "step-1",
          action: "inspect",
          target:
            "docs/contracts/example.md",
          instructions:
            "approval only",
          expected_output:
            "approval result",
        },
      ],
    },
    patch_spec: {
      format:
        "structured_patch",
      patches: [
        {
          file:
            "docs/contracts/example.md",
          operation: "modify",
          content: "planned only",
        },
      ],
    },
    validation_contract: {
      pre_checks: [],
      post_checks: [],
      success_criteria: [
        "push approval validation succeeds",
      ],
      failure_conditions: [],
    },
    rollback_contract: {
      rollback_supported: true,
      rollback_method: "git",
      rollback_trigger_conditions: [
        "validation failure",
      ],
    },
    reconciliation: {
      required: true,
      reconciliation_type:
        "diff_based",
    },
    sandbox: {
      dry_run_required: true,
      sandbox_mode: "strict",
      allow_external_side_effects:
        false,
    },
    execution_mode: {
      mutation_allowed: false,
      shell_execution_allowed: false,
      autonomous_execution_allowed:
        false,
    },
    delegation_authorization: {
      required: true,
      state: "delegated",
      notes:
        "push approval smoke only",
    },
  });
}

function approvedVc({
  push = false,
} = {}) {
  return {
    ...buildApprovalArtifact({
      version_control_authorization: {
        commit_authorized: true,
        push_authorized: push,
        remote: "origin",
        branch:
          "feature/support-source-references-runtime",
      },
    }),
    status: "approved",
  };
}

function localCommitResult({
  status = "ok",
  postHead = "b".repeat(40),
  branch =
    "feature/support-source-references-runtime",
  approvalId,
  envelopeId =
    "env-push-approval-smoke",
  remoteEffect = false,
  pushEffect = false,
} = {}) {
  return {
    status,
    preHead: head,
    postHead,
    branch,
    approvalId,
    envelopeId,
    executionId:
      "execution-push-smoke",
    remoteEffect,
    pushEffect,
  };
}

const envelope = buildEnvelope();
const governance =
  validateGovernedExecutionEnvelope(
    envelope,
  );

const ordinary =
  evaluateExecutionApproval({
    envelope,
    governance,
    approval:
      buildApprovalArtifact(),
  });

assert.equal(
  ordinary.execution_phase,
  "governed_planning_only",
);

const commitApproval =
  approvedVc({
    push: false,
  });

const commitOnly =
  evaluateExecutionApproval({
    envelope,
    governance,
    approval: commitApproval,
  });

assert.equal(
  commitOnly.execution_phase,
  "governed_version_control_commit",
);

assert.equal(
  commitOnly
    .version_control_authorization
    .push_authorized,
  false,
);

const pushApproval =
  approvedVc({
    push: true,
  });

const proof =
  localCommitResult({
    approvalId:
      pushApproval.approval_id,
  });

const pushed =
  evaluateExecutionApproval({
    envelope,
    governance,
    approval: pushApproval,
    localCommitResult: proof,
  });

assert.equal(
  pushed.execution_phase,
  "governed_version_control_push",
);

assert.equal(
  pushed
    .version_control_authorization
    .commit_authorized,
  true,
);

assert.equal(
  pushed
    .version_control_authorization
    .push_authorized,
  true,
);

assert.equal(
  pushed.mutation_authorized,
  false,
);

assert.equal(
  pushed.shell_execution_authorized,
  false,
);

assert.equal(
  pushed.autonomous_execution_authorized,
  false,
);

assert.equal(
  pushed.expected_push_head,
  proof.postHead,
);

assert.equal(
  pushed.trace.some(
    (entry) =>
      entry.event ===
      "governed_local_commit_verified",
  ),
  true,
);

assert.equal(
  pushed.trace.some(
    (entry) =>
      entry.event ===
      "push_authority_granted",
  ),
  true,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope,
      governance,
      approval: pushApproval,
    }),
  /local commit result/,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope,
      governance,
      approval: pushApproval,
      localCommitResult:
        localCommitResult({
          approvalId:
            pushApproval.approval_id,
          status: "failed",
        }),
    }),
  /status=ok/,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope,
      governance,
      approval: pushApproval,
      localCommitResult:
        localCommitResult({
          approvalId:
            "wrong-approval",
        }),
    }),
  /approval_id/,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope,
      governance,
      approval: pushApproval,
      localCommitResult:
        localCommitResult({
          approvalId:
            pushApproval.approval_id,
          envelopeId:
            "wrong-envelope",
        }),
    }),
  /envelope_id/,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope,
      governance,
      approval: pushApproval,
      localCommitResult:
        localCommitResult({
          approvalId:
            pushApproval.approval_id,
          branch:
            "wrong-branch",
        }),
    }),
  /branch/,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope,
      governance,
      approval: pushApproval,
      localCommitResult:
        localCommitResult({
          approvalId:
            pushApproval.approval_id,
          remoteEffect: true,
        }),
    }),
  /remote_effect=false/,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope,
      governance,
      approval: pushApproval,
      localCommitResult:
        localCommitResult({
          approvalId:
            pushApproval.approval_id,
          pushEffect: true,
        }),
    }),
  /push_effect=false/,
);

console.log(
  JSON.stringify(
    {
      ok: true,
      ordinary_planning_preserved:
        true,
      commit_only_phase_preserved:
        true,
      push_authority_granted:
        true,
      successful_local_commit_required:
        true,
      approval_correlation:
        true,
      envelope_correlation:
        true,
      branch_correlation:
        true,
      mutation_authority:
        false,
      shell_authority:
        false,
      autonomous_authority:
        false,
      git_side_effects:
        false,
      remote_write:
        false,
    },
    null,
    2,
  ),
);


const certifiedPriorProofEnvelope = buildEnvelope();

certifiedPriorProofEnvelope.identity = {
  ...certifiedPriorProofEnvelope.identity,
  package_id: "pkg-certified-prior",
  package_version: 1,
  envelope_id: "current-push-envelope",
};

certifiedPriorProofEnvelope.project_target = {
  ...certifiedPriorProofEnvelope.project_target,
  repo_path: "/tmp/certified-prior-repo",
  branch:
    "feature/support-source-references-runtime",
  expected_head: proof.postHead,
};

const certifiedPriorProofApproval = {
  ...approvedVc({
    push: true,
  }),
  approval_id: "current-push-approval",
};

const certifiedPriorProof = {
  status: "ok",
  pre_head: proof.preHead,
  post_head: proof.postHead,
  branch:
    "feature/support-source-references-runtime",
  approval_id: "prior-commit-approval",
  envelope_id: "prior-commit-envelope",
  execution_id: "prior-commit-execution",
  project_id: "hq",
  package_id: "pkg-certified-prior",
  package_version: 1,
  delegation_id: "prior-delegation",
  validation_result_id: "prior-validation",
  envelope_gate_id: "prior-gate",
  repo_path: "/tmp/certified-prior-repo",
  expected_head: proof.preHead,
  remote_effect: false,
  push_effect: false,
};

const certifiedPriorPush =
  evaluateExecutionApproval({
    envelope: certifiedPriorProofEnvelope,
    governance,
    approval: certifiedPriorProofApproval,
    localCommitResult: certifiedPriorProof,
  });

assert.equal(
  certifiedPriorPush.execution_phase,
  "governed_version_control_push",
);

assert.equal(
  certifiedPriorPush.expected_push_head,
  proof.postHead,
);

assert.equal(
  certifiedPriorPush.local_commit_result.approval_id,
  "prior-commit-approval",
);

assert.equal(
  certifiedPriorPush.local_commit_result.envelope_id,
  "prior-commit-envelope",
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope: certifiedPriorProofEnvelope,
      governance,
      approval: certifiedPriorProofApproval,
      localCommitResult: {
        ...certifiedPriorProof,
        package_id: "wrong-package",
      },
    }),
  /package lineage/,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope: certifiedPriorProofEnvelope,
      governance,
      approval: certifiedPriorProofApproval,
      localCommitResult: {
        ...certifiedPriorProof,
        repo_path: "/tmp/wrong-repo",
      },
    }),
  /repo_path/,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope: certifiedPriorProofEnvelope,
      governance,
      approval: certifiedPriorProofApproval,
      localCommitResult: {
        ...certifiedPriorProof,
        post_head: "f".repeat(40),
      },
    }),
  /expected_head/,
);
