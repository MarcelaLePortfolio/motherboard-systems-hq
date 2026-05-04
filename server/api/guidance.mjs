// Phase 663 — Guidance API Safety Restore
// Standalone read-only guidance endpoint.
// Execution pipeline remains untouched.

const guidance = [
  {
    id: "execution-subsystem-stable",
    severity: "info",
    message: "Execution subsystem is stable.",
    suggested_action: "Continue read-only validation.",
  },
  {
    id: "atlas-optional-offline",
    severity: "info",
    message: "Atlas is optional and may be offline without blocking execution.",
    suggested_action: "No action required unless Atlas is needed.",
  },
];

export default async function handler(req, res) {
  return res.status(200).json({
    ok: true,
    guidance_available: guidance.length > 0,
    guidance,
  });
}
