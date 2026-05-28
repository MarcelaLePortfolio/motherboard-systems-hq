
export function buildApprovalArtifact({

  requested_by = "Matilda",

  approval_scope = "planning_only",

  justification = "Governed planning validation",

} = {}) {

  return {

    approval_id: `approval-${Date.now()}`,

    approved_by: null,

    approval_scope,

    mutation_authorized: false,

    shell_execution_authorized: false,

    autonomous_execution_authorized: false,

    issued_at: new Date().toISOString(),

    expires_at: null,

    justification,

    requested_by,

    status: "approval_required",

  };

}

