import assert from "node:assert/strict";

import { createExecutionEnvelope } from "../contracts/execution-envelope.v1.mjs";
import { validateExecutionEnvelope } from "../guards/validate-execution-envelope.mjs";
import { buildApprovalArtifact } from "./build-approval-artifact.mjs";
import { evaluateExecutionApproval } from "./execution-approval-gate.mjs";
import { validateGovernedExecutionEnvelope } from "./governance-validator.mjs";

function buildEnvelope(projectTarget = {}, overrides = {}) {
  return createExecutionEnvelope({
    identity: {
      envelope_id: "env-version-control-contract-smoke",
      intent_id: "intent-version-control-contract-smoke",
    },
    intent: {
      raw_user_intent:
        "Validate version-control contract semantics only",
      normalized_intent:
        "Validate contract semantics",
      intent_type: "inspect",
      intent_evidence: ["user_authorization"],
      confidence_score: 1,
    },
    project_target: {
      project_name: "Motherboard Systems",
      repo_path: process.cwd(),
      branch: "feature/support-source-references-runtime",
      workspace_type: "motherboard_systems",
      ...projectTarget,
    },
    mutation_scope: {
      scope_type: "file",
      allowed_paths: ["docs/contracts/"],
      forbidden_paths: ["secrets/", ".env"],
      scope_constraints: "Contract-only smoke",
      ...(overrides.mutation_scope || {}),
    },
    execution_plan: {
      summary:
        "Validate version-control contract semantics",
      steps: [
        {
          step_id: "step-1",
          action: "inspect",
          target: "docs/contracts/example.md",
          instructions: "Plan only",
          expected_output: "Validated contract",
        },
      ],
    },
    patch_spec: {
      format: "structured_patch",
      patches: [
        {
          file: "docs/contracts/example.md",
          operation: "modify",
          content: "planned only",
        },
      ],
    },
    validation_contract: {
      pre_checks: [],
      post_checks: [],
      success_criteria: [
        "Contract validation succeeds",
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
      reconciliation_type: "diff_based",
    },
    sandbox: {
      dry_run_required: true,
      sandbox_mode: "strict",
      allow_external_side_effects: false,
    },
    execution_mode: {
      mutation_allowed: false,
      shell_execution_allowed: false,
      autonomous_execution_allowed: false,
    },
    delegation_authorization: {
      required: true,
      state: "delegated",
      notes: "Contract-only smoke",
      ...(overrides.delegation_authorization || {}),
    },
  });
}

function approvedCommitArtifact(overrides = {}) {
  return {
    ...buildApprovalArtifact({
      version_control_authorization: {
        commit_authorized: true,
        push_authorized: false,
        remote: "origin",
        branch:
          "feature/support-source-references-runtime",
      },
    }),
    status: "approved",
    ...overrides,
  };
}

const ordinary = buildEnvelope();
assert.equal(
  ordinary.project_target.expected_head,
  null,
);
assert.doesNotThrow(() =>
  validateExecutionEnvelope(ordinary),
);

const expectedHead = "a".repeat(40);
const withExpectedHead = buildEnvelope({
  expected_head: expectedHead,
});
assert.equal(
  withExpectedHead.project_target.expected_head,
  expectedHead,
);
assert.doesNotThrow(() =>
  validateExecutionEnvelope(withExpectedHead),
);

const malformedExpectedHead = buildEnvelope({
  expected_head: "not-a-git-sha",
});
assert.throws(
  () =>
    validateExecutionEnvelope(
      malformedExpectedHead,
    ),
  /expected_head/,
);

const defaults = buildApprovalArtifact();
assert.equal(
  defaults.version_control_authorization
    .commit_authorized,
  false,
);
assert.equal(
  defaults.version_control_authorization
    .push_authorized,
  false,
);
assert.equal(
  defaults.version_control_authorization.remote,
  "origin",
);
assert.equal(
  defaults.version_control_authorization.branch,
  null,
);

const commitOnly = buildApprovalArtifact({
  version_control_authorization: {
    commit_authorized: true,
    push_authorized: false,
    remote: "origin",
    branch:
      "feature/support-source-references-runtime",
  },
});

assert.equal(
  commitOnly.version_control_authorization
    .commit_authorized,
  true,
);
assert.equal(
  commitOnly.version_control_authorization
    .push_authorized,
  false,
);
assert.equal(
  commitOnly.mutation_authorized,
  false,
);
assert.equal(
  commitOnly.shell_execution_authorized,
  false,
);

const ordinaryGovernance =
  validateGovernedExecutionEnvelope(ordinary);

const ordinaryGated =
  evaluateExecutionApproval({
    envelope: ordinary,
    governance: ordinaryGovernance,
    approval: commitOnly,
  });

assert.equal(
  ordinaryGated.execution_phase,
  "governed_planning_only",
);
assert.equal(
  ordinaryGated.version_control_authorization
    .commit_authorized,
  false,
);
assert.equal(
  ordinaryGated.version_control_authorization
    .push_authorized,
  false,
);

const governedCommitEnvelope = buildEnvelope({
  expected_head: expectedHead,
});

const governedCommitGovernance =
  validateGovernedExecutionEnvelope(
    governedCommitEnvelope,
  );

const governedCommitApproval =
  approvedCommitArtifact();

const governedCommit =
  evaluateExecutionApproval({
    envelope: governedCommitEnvelope,
    governance: governedCommitGovernance,
    approval: governedCommitApproval,
  });

assert.equal(
  governedCommit.execution_phase,
  "governed_version_control_commit",
);
assert.equal(
  governedCommit.version_control_authorization
    .commit_authorized,
  true,
);
assert.equal(
  governedCommit.version_control_authorization
    .push_authorized,
  false,
);
assert.equal(
  governedCommit.mutation_authorized,
  false,
);
assert.equal(
  governedCommit.shell_execution_authorized,
  false,
);
assert.equal(
  governedCommit.autonomous_execution_authorized,
  false,
);

const missingHead =
  evaluateExecutionApproval({
    envelope: buildEnvelope(),
    governance: ordinaryGovernance,
    approval: approvedCommitArtifact(),
  });

assert.equal(
  missingHead.version_control_authorization
    .commit_authorized,
  false,
);

const noAllowedPathsEnvelope =
  buildEnvelope(
    { expected_head: expectedHead },
    {
      mutation_scope: {
        allowed_paths: [],
      },
    },
  );

assert.throws(
  () =>
    validateGovernedExecutionEnvelope(
      noAllowedPathsEnvelope,
    ),
  /allowed_paths required/,
);

const noAllowedPaths =
  evaluateExecutionApproval({
    envelope: noAllowedPathsEnvelope,
    governance: {
      ok: true,
    },
    approval: approvedCommitArtifact(),
  });

assert.equal(
  noAllowedPaths.version_control_authorization
    .commit_authorized,
  false,
);

const undelegatedEnvelope =
  buildEnvelope(
    { expected_head: expectedHead },
    {
      delegation_authorization: {
        state: "pending",
      },
    },
  );

assert.throws(
  () =>
    validateGovernedExecutionEnvelope(
      undelegatedEnvelope,
    ),
  /execution not delegated/,
);

const undelegated =
  evaluateExecutionApproval({
    envelope: undelegatedEnvelope,
    governance: {
      ok: true,
    },
    approval: approvedCommitArtifact(),
  });

assert.equal(
  undelegated.version_control_authorization
    .commit_authorized,
  false,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope: governedCommitEnvelope,
      governance: governedCommitGovernance,
      approval: approvedCommitArtifact({
        version_control_authorization: {
          commit_authorized: true,
          push_authorized: true,
          remote: "origin",
          branch:
            "feature/support-source-references-runtime",
        },
      }),
    }),
  /push authority remains disabled/,
);

assert.throws(
  () =>
    evaluateExecutionApproval({
      envelope: governedCommitEnvelope,
      governance: { ok: false },
      approval: governedCommitApproval,
    }),
  /governance validation/,
);

assert.equal(
  governedCommit.trace.some(
    (entry) =>
      entry.event ===
      "version_control_commit_authority_granted",
  ),
  true,
);

console.log(
  JSON.stringify(
    {
      ok: true,
      ordinary_planning_backward_compatible:
        true,
      expected_head_preserved: true,
      malformed_expected_head_failed_closed:
        true,
      commit_authorization_default_false:
        true,
      push_authorization_default_false:
        true,
      commit_does_not_imply_push: true,
      governed_commit_authority_granted:
        true,
      push_remains_blocked: true,
      mutation_remains_blocked: true,
      shell_remains_blocked: true,
      autonomous_remains_blocked: true,
      missing_expected_head_blocks_commit:
        true,
      empty_allowed_paths_blocks_commit:
        true,
      undelegated_request_blocks_commit:
        true,
      governance_failure_blocks_commit:
        true,
      git_side_effects: false,
    },
    null,
    2,
  ),
);
