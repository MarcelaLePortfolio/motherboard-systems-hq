import fs from "node:fs";
import { normalizePolicyAudit } from "./policy_audit_shape.mjs";

/**
 * Audit sink.
 * - Always stdout JSON line.
 * - Optional local capture when POLICY_AUDIT_PATH is set (append-only JSONL).
 * - Must not throw.
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

    const path = env?.POLICY_AUDIT_PATH ? String(env.POLICY_AUDIT_PATH) : "";
    if (path) {
      try {
        fs.appendFileSync(path, line + "\n", { encoding: "utf8" });
      } catch (_) {
        // swallow
      }
    }
  } catch (_) {
    // swallow
  }
}
