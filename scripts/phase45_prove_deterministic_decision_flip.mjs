/**
 * Phase 45 proof: deterministic decision flip with resolvePolicyGrant integrated.
 *
 * This repo's canonical evaluator signature (per server/policy/evaluate.legacy.mjs):
 *   evaluatePolicy({ action_id, context = {}, meta = {} }, { policy })
 *
 * Proof (best-effort):
 * 1) legacy evaluatePolicy is deterministic (same inputs => same JSON)
 * 2) wrapped evaluatePolicy is deterministic
 * 3) if grant resolution returns an allow/override signal for this action_id and legacy denies,
 *    wrapped deterministically flips to allow
 *
 * Notes:
 * - Uses repo default policy via loadDefaultPolicyFromRepoRoot().
 * - action_id can be overridden with PHASE45_ACTION_ID for targeting a deny-default action.
 */

import path from "node:path";
import process from "node:process";
import crypto from "node:crypto";

function stableStringify(x) {
  const seen = new WeakSet();
  return JSON.stringify(
    x,
    (k, v) => {
      if (v && typeof v === "object") {
        if (seen.has(v)) return "[Circular]";
        seen.add(v);
      }
      return v;
    },
    2
  );
}

function sha256(s) {
  return crypto.createHash("sha256").update(s).digest("hex");
}

function deepEqualJson(a, b) {
  return stableStringify(a) === stableStringify(b);
}

function normalizeAllowed(result) {
  if (!result || typeof result !== "object") return null;
  if (typeof result.allowed === "boolean") return result.allowed;
  if (typeof result.decision === "string") {
    const d = result.decision.toLowerCase();
    if (["allow", "permit", "approved", "approve", "ok"].includes(d)) return true;
    if (["deny", "block", "blocked", "reject", "rejected", "no"].includes(d)) return false;
    if (d === "allow_with_conditions") return true;
  }
  return null;
}

function isGrantAllow(grantResult) {
  if (!grantResult) return false;
  if (typeof grantResult.allow === "boolean") return grantResult.allow;
  if (typeof grantResult.allowed === "boolean") return grantResult.allowed;
  if (typeof grantResult.decision === "string") {
    const d = grantResult.decision.toLowerCase();
    if (["allow", "permit", "approved", "approve", "ok"].includes(d)) return true;
    if (d === "allow_with_conditions") return true;
  }
  if (typeof grantResult.effect === "string") {
    const e = grantResult.effect.toLowerCase();
    if (e.includes("allow") || e.includes("override")) return true;
  }
  if (grantResult.applies === true && typeof grantResult.outcome === "string") {
    const o = grantResult.outcome.toLowerCase();
    if (o.includes("allow") || o.includes("override")) return true;
  }
  return false;
}

async function main() {
  const repoRoot = process.cwd();

  const legacyMod = await import(path.join(repoRoot, "server/policy/evaluate.legacy.mjs"));
  const wrappedMod = await import(path.join(repoRoot, "server/policy/evaluate.mjs"));
  const grantsMod = await import(path.join(repoRoot, "server/policy/resolvePolicyGrant.mjs"));

  if (typeof legacyMod?.evaluatePolicy !== "function") {
    throw new TypeError("Legacy module missing evaluatePolicy export");
  }
  if (typeof wrappedMod?.evaluatePolicy !== "function") {
    throw new TypeError("Wrapped module missing evaluatePolicy export");
  }
  if (typeof legacyMod?.loadDefaultPolicyFromRepoRoot !== "function") {
    throw new TypeError("Legacy module missing loadDefaultPolicyFromRepoRoot export");
  }
  if (typeof grantsMod?.resolvePolicyGrant !== "function") {
    throw new TypeError("resolvePolicyGrant export is not a function");
  }

  const { policy, path: policyPath } = legacyMod.loadDefaultPolicyFromRepoRoot(repoRoot);

  // Choose an action_id (overrideable) — aim for something likely to be unknown/denied by default.
  const action_id = (process.env.PHASE45_ACTION_ID && process.env.PHASE45_ACTION_ID.trim())
    ? process.env.PHASE45_ACTION_ID.trim()
    : "phase45.proof.unknown_action";

  const input1 = { action_id, context: {}, meta: {} };
  const input2 = { policy };

  const legacy1 = legacyMod.evaluatePolicy(input1, input2);
  const legacy2 = legacyMod.evaluatePolicy(input1, input2);

  if (!deepEqualJson(legacy1, legacy2)) {
    console.error("FAIL: legacy evaluator is not deterministic");
    console.error("legacy1_sha=", sha256(stableStringify(legacy1)));
    console.error("legacy2_sha=", sha256(stableStringify(legacy2)));
    process.exit(2);
  }

  const wrap1 = await wrappedMod.evaluatePolicy(input1, input2);
  const wrap2 = await wrappedMod.evaluatePolicy(input1, input2);

  if (!deepEqualJson(wrap1, wrap2)) {
    console.error("FAIL: wrapped evaluator is not deterministic");
    console.error("wrap1_sha=", sha256(stableStringify(wrap1)));
    console.error("wrap2_sha=", sha256(stableStringify(wrap2)));
    process.exit(3);
  }

  const grantInput = { action_id, context: {}, meta: {}, policy };
  const grant = await grantsMod.resolvePolicyGrant({ ...grantInput, _phase45_probe: true });
  const grantAllows = isGrantAllow(grant);

  const legacyAllowed = normalizeAllowed(legacy1);
  const wrapAllowed = normalizeAllowed(wrap1);

  console.log("policy_path=", policyPath);
  console.log("action_id=", action_id);
  console.log("legacy_decision=", legacy1?.decision ?? null, "legacy_tier=", legacy1?.tier ?? null);
  console.log("wrapped_decision=", wrap1?.decision ?? null, "wrapped_tier=", wrap1?.tier ?? null);
  console.log("grant_allows=", grantAllows);

  if (legacyAllowed === false && grantAllows && wrapAllowed === true) {
    console.log("OK: deterministic decision flip proven (deny -> allow via grant)");
    process.exit(0);
  }

  console.error("FAIL: could not prove deny->allow flip with current grant semantics for this action_id.");
  console.error("TIP: set PHASE45_ACTION_ID to an action your default policy denies, and ensure a grant can allow it.");
  process.exit(4);
}

main().catch((e) => {
  console.error("ERROR:", e?.stack || String(e));
  process.exit(1);
});
