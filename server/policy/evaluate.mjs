/**
 * Phase 45: integrate resolvePolicyGrant into evaluation pipeline.
 *
 * Strategy:
 * - Preserve existing evaluator logic in `evaluate.legacy.mjs`
 * - Re-export everything from legacy for compatibility
 * - Wrap the primary evaluator function (default / evaluatePolicy / evaluate) if present
 * - Apply a deterministic post-step:
 *     - compute legacy decision
 *     - compute grant resolution (pure input -> grant result)
 *     - if grant indicates override/allow, flip result deterministically and annotate
 *
 * This wrapper avoids invasive edits to the legacy evaluator.
 */

import * as legacy from "./evaluate.legacy.mjs";
import { resolvePolicyGrant } from "./resolvePolicyGrant.mjs";

export * from "./evaluate.legacy.mjs";

function pickLegacyEvalFn() {
  const candidates = [
    legacy.evaluatePolicy,
    legacy.evaluate,
    legacy.default,
  ];
  for (const fn of candidates) {
    if (typeof fn === "function") return fn;
  }
  return null;
}

function normalizeAllowed(result) {
  if (!result || typeof result !== "object") return null;

  // Common patterns:
  // - { allowed: true/false }
  if (typeof result.allowed === "boolean") return result.allowed;

  // - { decision: "allow"|"deny"|"block"|"permit"|... }
  if (typeof result.decision === "string") {
    const d = result.decision.toLowerCase();
    if (["allow", "permit", "approved", "approve", "ok"].includes(d)) return true;
    if (["deny", "block", "blocked", "reject", "rejected", "no"].includes(d)) return false;
  }

  // - { action_tier: "A"|"B"|"C" } (assume A=allow; B/C=block unless overridden)
  if (typeof result.action_tier === "string") {
    const t = result.action_tier.toUpperCase();
    if (t === "A") return true;
    if (t === "B" || t === "C") return false;
  }

  return null;
}

function applyFlip(result, flipToAllowed, grantInfo) {
  if (!result || typeof result !== "object") {
    return {
      legacy_result: result,
      allowed: !!flipToAllowed,
      decision: flipToAllowed ? "allow" : "deny",
      policy_grant_applied: true,
      policy_grant: grantInfo ?? null,
    };
  }

  // Clone shallowly to avoid mutating legacy output.
  const out = { ...result };

  // Set/normalize decision fields.
  if (typeof out.allowed === "boolean" || out.allowed == null) out.allowed = !!flipToAllowed;

  if (typeof out.decision === "string" || out.decision == null) {
    out.decision = flipToAllowed ? "allow" : "deny";
  }

  // If tiers exist, prefer A when allowed.
  if (typeof out.action_tier === "string") {
    out.action_tier = flipToAllowed ? "A" : out.action_tier;
  }

  out.policy_grant_applied = true;
  out.policy_grant = grantInfo ?? null;

  return out;
}

function isGrantAllow(grantResult) {
  if (!grantResult) return false;

  // Common patterns:
  // - { allow: true }
  if (typeof grantResult.allow === "boolean") return grantResult.allow;

  // - { allowed: true }
  if (typeof grantResult.allowed === "boolean") return grantResult.allowed;

  // - { decision: "allow" }
  if (typeof grantResult.decision === "string") {
    const d = grantResult.decision.toLowerCase();
    if (["allow", "permit", "approved", "approve", "ok"].includes(d)) return true;
  }

  // - { effect: "allow"|"override_allow" }
  if (typeof grantResult.effect === "string") {
    const e = grantResult.effect.toLowerCase();
    if (e.includes("allow") || e.includes("override")) return true;
  }

  // - { applies: true, outcome: "allow" }
  if (grantResult.applies === true && typeof grantResult.outcome === "string") {
    const o = grantResult.outcome.toLowerCase();
    if (o.includes("allow") || o.includes("override")) return true;
  }

  return false;
}

function buildGrantInput(args, legacyResult) {
  // Heuristic: pass through a structured object if the first arg looks like one.
  const a0 = args?.[0];
  if (a0 && typeof a0 === "object" && !Array.isArray(a0)) {
    return {
      ...a0,
      legacy_decision: legacyResult,
    };
  }
  return {
    args,
    legacy_decision: legacyResult,
  };
}

const legacyFn = pickLegacyEvalFn();

if (!legacyFn) {
  throw new Error(
    "Phase 45 wrapper: could not find legacy evaluator function export. Expected one of: evaluatePolicy, evaluate, default."
  );
}

// Maintain a default export (common import style).
export default async function evaluatePolicyWithGrant(...args) {
  const legacyResult = await legacyFn(...args);
  const legacyAllowed = normalizeAllowed(legacyResult);

  // Always resolve grants deterministically based on the same stable input.
  const grantInput = buildGrantInput(args, legacyResult);
  const grantResult = await resolvePolicyGrant(grantInput);

  const grantAllows = isGrantAllow(grantResult);

  // If legacy is already allowed, keep it allowed; still annotate if a grant applies.
  if (legacyAllowed === true) {
    if (grantAllows) {
      return applyFlip(legacyResult, true, grantResult);
    }
    return legacyResult;
  }

  // If legacy blocks/denies and grant allows, flip deterministically.
  if (legacyAllowed === false && grantAllows) {
    return applyFlip(legacyResult, true, grantResult);
  }

  // If legacyAllowed is unknown, do not flip (safe default) but still allow downstream inspection.
  return legacyResult;
}

// Preserve named entrypoints if callers use them.
export const evaluatePolicy = evaluatePolicyWithGrant;
export const evaluate = evaluatePolicyWithGrant;
