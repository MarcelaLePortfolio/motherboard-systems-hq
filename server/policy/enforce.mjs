export function policyEnforceEnabled() {
  const v = String(process.env.POLICY_ENFORCE_MODE ?? process.env.POLICY_MODE ?? "")
    .trim()
    .toLowerCase();
  return v === "1" || v === "true" || v === "yes" || v === "on" || v === "enforce" || v === "enabled";
}

export class PolicyEnforcedError extends Error {
  constructor(message = "mutation blocked by enforcement gate") {
    super(message);
    this.name = "PolicyEnforcedError";
    this.status = 403;
    this.statusCode = 403;
    this.code = "POLICY_ENFORCED";
  }
}

export function assertNotEnforced(detail = "write-path") {
  if (!policyEnforceEnabled()) return;
  throw new PolicyEnforcedError(`policy.enforce: ${detail}`);
}
