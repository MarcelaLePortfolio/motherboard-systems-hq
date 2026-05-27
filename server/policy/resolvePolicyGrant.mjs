/**
 * Phase 45: Stable shim for resolvePolicyGrant.
 *
 * Goal:
 * - Provide a single, stable import path: `server/policy/resolvePolicyGrant.mjs`
 * - Delegate to the project's real grant resolver if it exists (in any of several common locations)
 * - Fail loudly if no implementation is found
 *
 * This file is intentionally defensive to avoid path churn.
 */

const CANDIDATES = [
  "./grants/resolvePolicyGrant.mjs",
  "./grants/resolvePolicyGrant.js",
  "./grants/resolvePolicyGrant/index.mjs",
  "./grants/resolvePolicyGrant/index.js",
  "./grant/resolvePolicyGrant.mjs",
  "./grant/resolvePolicyGrant.js",
  "./resolvePolicyGrant.impl.mjs",
  "./resolvePolicyGrant.impl.js",
];

async function loadImpl() {
  const errors = [];
  for (const rel of CANDIDATES) {
    try {
      const mod = await import(rel);
      const fn =
        mod?.resolvePolicyGrant ||
        mod?.default;

      if (typeof fn === "function") {
        return { mod, fn, rel };
      }

      errors.push(`Found ${rel} but no function export (resolvePolicyGrant/default).`);
    } catch (e) {
      errors.push(`Tried ${rel}: ${String(e?.message || e)}`);
    }
  }

  const msg =
    "resolvePolicyGrant implementation not found.\n" +
    "Searched:\n" +
    CANDIDATES.map((p) => `- ${p}`).join("\n") +
    "\n\nErrors:\n" +
    errors.map((s) => `- ${s}`).join("\n");

  const err = new Error(msg);
  err.code = "POLICY_GRANT_IMPL_NOT_FOUND";
  throw err;
}

let _implP = null;
async function getImpl() {
  if (!_implP) _implP = loadImpl();
  return _implP;
}

export async function resolvePolicyGrant(input) {
  const { fn } = await getImpl();
  return await fn(input);
}

export async function _debug_resolvePolicyGrant_implInfo() {
  const { rel, mod } = await getImpl();
  return { rel, keys: Object.keys(mod || {}) };
}
