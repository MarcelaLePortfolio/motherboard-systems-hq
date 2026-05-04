export function policyShadowEnabled(env = process.env) {
  return String(env.POLICY_SHADOW_MODE || "0") === "1";
}

export function policyEnforceEnabled(env = process.env) {
  // Explicitly off-by-default. Shadow-mode wiring should not enforce unless this is enabled.
  return String(env.POLICY_ENFORCE_MODE || "0") === "1";
}
