import { normalizePolicyAudit } from "./policy_audit_shape.mjs";

/**
 * Audit sink (stdout-only).
 * Must not throw.
 */
export async function policyAuditWrite(audit = {}, env = process.env) {
  try {
    const normalized = normalizePolicyAudit(audit, env);
    const line = JSON.stringify({
      t: normalized.meta.emitted_at_iso,
      channel: "policy_audit",
      audit: normalized,
    });
    // eslint-disable-next-line no-console
    console.log(line);
  } catch (_) {
    // swallow
  }
}
