/**
 * Phase 40.2 — Shadow audit shape normalization
 * Goal: stable, explicit audit envelope without changing enforcement behavior.
 *
 * NOTE: This is audit-only. No writes beyond stdout JSON line emission.
 */

function pickEnv(env, keys) {
  for (const k of keys) {
    const v = env?.[k];
    if (v != null && String(v).length) return String(v);
  }
  return null;
}

export function normalizePolicyAudit(input = {}, env = process.env) {
  const nowMs = Date.now();

  const version = input?.version ?? "policy-shadow-v1";

  const decision = {
    allow: Boolean(input?.decision?.allow ?? true),
    enforce: Boolean(input?.decision?.enforce ?? false),
    reasons: Array.isArray(input?.decision?.reasons) ? input.decision.reasons : [],
    confidence: input?.decision?.confidence ?? "unknown",
  };

  const signals = input?.signals ?? {};

  const meta = {
    emitted_at_ms: nowMs,
    emitted_at_iso: new Date(nowMs).toISOString(),
    emitted_by: pickEnv(env, ["WORKER_ID", "WORKER_NAME", "HOSTNAME"]) ?? "unknown",
    pid: typeof process !== "undefined" ? process.pid : null,
    node: typeof process !== "undefined" ? process.version : null,
    phase: "40.2",
    shadow_mode: String(env?.POLICY_SHADOW_MODE || "0") === "1",
    enforce_mode: String(env?.POLICY_ENFORCE_MODE || "0") === "1",
  };

  return { version, decision, signals, meta };
}
