export function buildApprovalArtifact({
  requested_by = "Matilda",
  approval_scope = "planning_only",
  justification = "Governed planning validation",
  version_control_authorization = {},
} = {}) {
  return {
    approval_id: `approval-${Date.now()}`,
    approved_by: null,
    approval_scope,
    mutation_authorized: false,
    shell_execution_authorized: false,
    autonomous_execution_authorized: false,
    version_control_authorization: {
      commit_authorized:
        version_control_authorization?.commit_authorized === true,
      push_authorized:
        version_control_authorization?.push_authorized === true,
      remote:
        typeof version_control_authorization?.remote === "string" &&
        version_control_authorization.remote.length > 0
          ? version_control_authorization.remote
          : "origin",
      branch:
        typeof version_control_authorization?.branch === "string" &&
        version_control_authorization.branch.length > 0
          ? version_control_authorization.branch
          : null,
    },
    issued_at: new Date().toISOString(),
    expires_at: null,
    justification,
    requested_by,
    status: "approval_required",
  };
}
