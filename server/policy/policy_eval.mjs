import { policyEnforceEnabled } from "./policy_flags.mjs";

/**
 * Shadow-mode policy evaluation.
 * - Must be side-effect free.
 * - Returns an audit payload (and would-be enforcement decision).
 */
export async function policyEvalShadow(ctx = {}, env = process.env) {
  const now = Date.now();

  const task = ctx.task ?? ctx?.payload?.task ?? null;
  const run = ctx.run ?? ctx?.payload?.run ?? null;

  // Minimal, deterministic, non-hallucinated signals:
  const signals = {
    task_id: task?.task_id ?? task?.taskId ?? task?.id ?? null,
    run_id: run?.run_id ?? run?.runId ?? run?.id ?? null,
    kind: task?.kind ?? task?.type ?? null,
    action_tier: task?.action_tier ?? task?.actionTier ?? null,
    attempts: task?.attempts ?? null,
    max_attempts: task?.max_attempts ?? task?.maxAttempts ?? null,
    claimed_by: task?.claimed_by ?? task?.claimedBy ?? null,
    now_ms: now,
  };

  // Shadow-only decision skeleton (no enforcement unless explicitly enabled elsewhere).
  // Keep conservative: default allow with unknown confidence.
  const decision = {
    allow: true,
    enforce: policyEnforceEnabled(env),
    reasons: [],
    confidence: "unknown",
  };

  // Example deterministic checks (no blocking in shadow mode):
  if (signals.action_tier && !["A", "B", "C"].includes(String(signals.action_tier))) {
    decision.reasons.push({ code: "unknown_action_tier", value: String(signals.action_tier) });
  }

  return {
    version: "policy-shadow-v1",
    decision,
    signals,
  };
}
