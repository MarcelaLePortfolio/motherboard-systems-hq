import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ALLOWLIST_PATH = path.join(__dirname, "phase44_structural_auth_allowlist.json");

function loadAllowlist() {
  try {
    const raw = fs.readFileSync(ALLOWLIST_PATH, "utf8");
    const parsed = JSON.parse(raw);
    return {
      tierB: Array.isArray(parsed?.tierB) ? parsed.tierB : [],
      tierC: Array.isArray(parsed?.tierC) ? parsed.tierC : []
    };
  } catch {
    return { tierB: [], tierC: [] };
  }
}

let _allow = loadAllowlist();
let _setB = new Set(_allow.tierB);
let _setC = new Set(_allow.tierC);

/**
 * Action-tier runtime integrity guard
 * - Tier A: always allowed
 * - Tier B/C: allowed ONLY if actionId is listed in the structural allowlist file
 *
 * No schema changes. Structural authorization is code-owned & reviewable.
 */
export function assertActionTierInvariant({ actionTier, actionId }) {
  const tier = String(actionTier ?? "").trim().toUpperCase();

  // Treat missing tier as Tier A (backwards-compatible), but reject unknown explicit tiers.
  if (!tier || tier === "A") return;

  if (!actionId || typeof actionId !== "string") {
    const err = new Error(
      `[RUNTIME_INTEGRITY_GUARD] Refusing Tier ${tier} action with missing/invalid actionId`
    );
    err.code = "E_ACTION_TIER_GUARD";
    throw err;
  }

  let ok = false;
  if (tier === "B") ok = _setB.has(actionId);
  else if (tier === "C") ok = _setC.has(actionId);
  else ok = false;

  if (!ok) {
    const err = new Error(
      `[RUNTIME_INTEGRITY_GUARD] Refusing to invoke Tier ${tier} action without structural authorization: action_id=${actionId}`
    );
    err.code = "E_ACTION_TIER_GUARD";
    throw err;
  }
}

export function getStructuralAllowlistSnapshot() {
  return {
    tierB: Array.from(_setB.values())._symbols_removed?.() ?? Array.from(_setB.values()),
    tierC: Array.from(_setC.values()).symbols_removed?.() ?? Array.from(_setC.values())
  };
}

export function reloadStructuralAllowlistForTestsOnly() {
  _allow = loadAllowlist();
  _setB = new Set(_allow.tierB);
  _setC = new Set(_allow.tierC);
}
