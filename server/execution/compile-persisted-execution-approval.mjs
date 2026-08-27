export function compilePersistedExecutionApproval(record = {}) {
  if (
    !record ||
    record.status !== "approved" ||
    typeof record.approval_id !== "string" ||
    record.approval_id.length === 0 ||
    typeof record.approved_by !== "string" ||
    record.approved_by.length === 0
  ) {
    throw new Error(
      "Persisted execution approval is invalid or not approved.",
    );
  }

  if (
    record.push_authorized === true &&
    record.commit_authorized !== true
  ) {
    throw new Error(
      "Persisted push approval requires commit authorization.",
    );
  }

  return {
    approval_id: record.approval_id,
    approved_by: record.approved_by,
    approval_scope: record.approval_scope,
    mutation_authorized: false,
    shell_execution_authorized: false,
    autonomous_execution_authorized: false,
    version_control_authorization: {
      commit_authorized: record.commit_authorized === true,
      push_authorized: record.push_authorized === true,
      remote: record.remote,
      branch: record.branch,
    },
    issued_at: record.issued_at,
    expires_at: record.expires_at ?? null,
    justification: record.justification ?? null,
    status: "approved",
  };
}
