/**
 * Audit sink (stdout-only).
 * Must not throw.
 */
export async function policyAuditWrite(audit = {}) {
  try {
    const line = JSON.stringify({
      t: new Date().toISOString(),
      channel: "policy_audit",
      audit,
    });
    // eslint-disable-next-line no-console
    console.log(line);
  } catch (_) {
    // swallow
  }
}
