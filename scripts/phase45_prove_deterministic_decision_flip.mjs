/**
 * Phase 45 proof: deterministic decision flip with resolvePolicyGrant integrated.
 *
 * What it proves (best-effort across evolving schemas):
 * 1) Legacy evaluator is deterministic: same input -> same output (deep-equal JSON)
 * 2) Wrapper evaluator is deterministic: same input -> same output
 * 3) If a grant can produce an allow/override signal for this input, wrapper flips vs legacy deterministically
 *
 * Notes:
 * - This script searches for an existing "probe/example" JSON payload in-repo.
 * - If none is found, it synthesizes a minimal payload shape and still proves determinism.
 * - If grant resolution can't apply on the chosen payload, it still proves determinism and exits non-zero
 *   so you notice you need a better fixture for your repo's grant semantics.
 */

import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";
import crypto from "node:crypto";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function stableStringify(x) {
  return JSON.stringify(x, Object.keys(x || {}).sort(), 2);
}

function sha256(s) {
  return crypto.createHash("sha256").update(s).digest("hex");
}

function deepEqualJson(a, b) {
  return stableStringify(a) === stableStringify(b);
}

function pickFixture() {
  const root = process.cwd();
  const candidates = [];

  function walk(dir) {
    const ents = fs.readdirSync(dir, { withFileTypes: true });
    for (const e of ents) {
      const p = path.join(dir, e.name);
      if (e.isDirectory()) {
        if (e.name === "node_modules" || e.name === ".git" || e.name === "dist" || e.name === ".next") continue;
        walk(p);
      } else if (e.isFile() && e.name.toLowerCase().endsWith(".json")) {
        const n = p.toLowerCase();
        if (
          n.includes("policy") &&
          (n.includes("probe") || n.includes("example") || n.includes("fixture") || n.includes("scenario"))
        ) {
          candidates.push(p);
        }
      }
    }
  }

  walk(root);

  if (candidates.length > 0) return candidates.sort()[0];
  return null;
}

function loadJson(p) {
  return JSON.parse(fs.readFileSync(p, "utf8"));
}

function normalizeAllowed(result) {
  if (!result || typeof result !== "object") return null;
  if (typeof result.allowed === "boolean") return result.allowed;
  if (typeof result.decision === "string") {
    const d = result.decision.toLowerCase();
    if (["allow", "permit", "approved", "approve", "ok"].includes(d)) return true;
    if (["deny", "block", "blocked", "reject", "rejected", "no"].includes(d)) return false;
  }
  if (typeof result.action_tier === "string") {
    const t = result.action_tier.toUpperCase();
    if (t === "A") return true;
    if (t === "B" || t === "C") return false;
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
  const fixturePath = pickFixture();
  const fixture = fixturePath
    ? loadJson(fixturePath)
    : {
        // minimal synthesized input; may not trigger grants, but proves determinism
        action: "demo.action",
        actor: "phase45.proof",
        payload: { hello: "world" },
      };

  const { default: legacyEval } = await import(path.join(process.cwd(), "server/policy/evaluate.legacy.mjs"));
  const { default: wrappedEval } = await import(path.join(process.cwd(), "server/policy/evaluate.mjs"));
  const { resolvePolicyGrant } = await import(path.join(process.cwd(), "server/policy/resolvePolicyGrant.mjs"));

  const legacy1 = await legacyEval(fixture);
  const legacy2 = await legacyEval(fixture);
  if (!deepEqualJson(legacy1, legacy2)) {
    console.error("FAIL: legacy evaluator is not deterministic on chosen fixture");
    console.error("legacy1_sha=", sha256(stableStringify(legacy1)));
    console.error("legacy2_sha=", sha256(stableStringify(legacy2)));
    process.exit(2);
  }

  const wrap1 = await wrappedEval(fixture);
  const wrap2 = await wrappedEval(fixture);
  if (!deepEqualJson(wrap1, wrap2)) {
    console.error("FAIL: wrapped evaluator is not deterministic on chosen fixture");
    console.error("wrap1_sha=", sha256(stableStringify(wrap1)));
    console.error("wrap2_sha=", sha256(stableStringify(wrap2)));
    process.exit(3);
  }

  const grant = await resolvePolicyGrant({ ...fixture, _phase45_probe: true });
  const grantAllows = isGrantAllow(grant);

  const legacyAllowed = normalizeAllowed(legacy1);
  const wrapAllowed = normalizeAllowed(wrap1);

  console.log("fixture=", fixturePath || "(synthesized)");
  console.log("legacy_allowed=", legacyAllowed);
  console.log("wrapped_allowed=", wrapAllowed);
  console.log("grant_allows=", grantAllows);

  // We only assert a flip if:
  // - legacy is definitively denied/blocked
  // - grant allows
  // - wrapper is allowed
  if (legacyAllowed === false && grantAllows && wrapAllowed === true) {
    console.log("OK: deterministic decision flip proven (deny -> allow via grant)");
    process.exit(0);
  }

  // If we can’t prove flip with the chosen fixture, still return non-zero so it’s actionable.
  console.error("FAIL: could not prove deny->allow flip with current fixture/grant semantics.");
  console.error("ACTION: add/adjust a policy probe fixture JSON that is blocked by default but becomes allowed when a grant applies.");
  process.exit(4);
}

main().catch((e) => {
  console.error("ERROR:", e?.stack || String(e));
  process.exit(1);
});
