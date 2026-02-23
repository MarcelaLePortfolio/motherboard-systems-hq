/**
 * Phase 48 — deterministic enforcement probe
 * POST /api/policy/probe
 * - 200 when POLICY_ENFORCE_ENABLED is falsey
 * - 403 when POLICY_ENFORCE_ENABLED is truthy
 */
function isTrue(v) {
  const s = String(v || "").trim().toLowerCase();
  return s === "1" || s === "true" || s === "yes";
}

export function registerPhase48PolicyProbe(app) {
  app.post("/api/policy/probe", (req, res) => {
    const enforce = isTrue(process.env.POLICY_ENFORCE_ENABLED);
    if (enforce) {
      return res.status(403).json({ ok: false, blocked: true, reason: "policy_enforce_enabled" });
    }
    return res.status(201).json({ ok: true, blocked: false });
  });
}
