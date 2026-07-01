
/**

 * Policy evaluator entrypoint.

 *

 * Named exports remain synchronous and deterministic for policy callers/tests.

 * The default export preserves the async grant-aware wrapper path.

 */

import * as legacy from "./evaluate.legacy.mjs";

import { resolvePolicyGrant } from "./resolvePolicyGrant.mjs";

export * from "./evaluate.legacy.mjs";

function pickLegacyEvalFn() {

  const candidates = [legacy.evaluatePolicy, legacy.evaluate, legacy.default];

  for (const fn of candidates) {

    if (typeof fn === "function") return fn;

  }

  return null;

}

function normalizeAllowed(result) {

  if (!result || typeof result !== "object") return null;

  if (typeof result.allowed === "boolean") return result.allowed;

  if (typeof result.decision === "string") {

    const decision = result.decision.toLowerCase();

    if (["allow", "permit", "approved", "approve", "ok"].includes(decision)) {

      return true;

    }

    if (["deny", "block", "blocked", "reject", "rejected", "no"].includes(decision)) {

      return false;

    }

  }

  if (typeof result.action_tier === "string") {

    const tier = result.action_tier.toUpperCase();

    if (tier === "A") return true;

    if (tier === "B" || tier === "C") return false;

  }

  return null;

}

function applyFlip(result, flipToAllowed, grantInfo) {

  if (!result || typeof result !== "object") {

    return {

      legacy_result: result,

      allowed: Boolean(flipToAllowed),

      decision: flipToAllowed ? "allow" : "deny",

      policy_grant_applied: true,

      policy_grant: grantInfo ?? null,

    };

  }

  const output = { ...result };

  if (typeof output.allowed === "boolean" || output.allowed == null) {

    output.allowed = Boolean(flipToAllowed);

  }

  if (typeof output.decision === "string" || output.decision == null) {

    output.decision = flipToAllowed ? "allow" : "deny";

  }

  if (typeof output.action_tier === "string") {

    output.action_tier = flipToAllowed ? "A" : output.action_tier;

  }

  output.policy_grant_applied = true;

  output.policy_grant = grantInfo ?? null;

  return output;

}

function isGrantAllow(grantResult) {

  if (!grantResult) return false;

  if (typeof grantResult.allow === "boolean") return grantResult.allow;

  if (typeof grantResult.allowed === "boolean") return grantResult.allowed;

  if (typeof grantResult.decision === "string") {

    const decision = grantResult.decision.toLowerCase();

    if (["allow", "permit", "approved", "approve", "ok"].includes(decision)) {

      return true;

    }

  }

  if (typeof grantResult.effect === "string") {

    const effect = grantResult.effect.toLowerCase();

    if (effect.includes("allow") || effect.includes("override")) return true;

  }

  if (grantResult.applies === true && typeof grantResult.outcome === "string") {

    const outcome = grantResult.outcome.toLowerCase();

    if (outcome.includes("allow") || outcome.includes("override")) return true;

  }

  return false;

}

function buildGrantInput(args, legacyResult) {

  const first = args?.[0];

  if (first && typeof first === "object" && !Array.isArray(first)) {

    return {

      ...first,

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

    "Policy evaluator could not find a legacy evaluator export. Expected evaluatePolicy, evaluate, or default.",

  );

}

export const evaluatePolicy = legacy.evaluatePolicy;

export const evaluate = legacy.evaluate ?? legacy.evaluatePolicy;

export default async function evaluatePolicyWithGrant(...args) {

  const legacyResult = legacyFn(...args);

  const legacyAllowed = normalizeAllowed(legacyResult);

  const grantInput = buildGrantInput(args, legacyResult);

  const grantResult = await resolvePolicyGrant(grantInput);

  const grantAllows = isGrantAllow(grantResult);

  if (legacyAllowed === true) {

    if (grantAllows) return applyFlip(legacyResult, true, grantResult);

    return legacyResult;

  }

  if (legacyAllowed === false && grantAllows) {

    return applyFlip(legacyResult, true, grantResult);

  }

  return legacyResult;

}

