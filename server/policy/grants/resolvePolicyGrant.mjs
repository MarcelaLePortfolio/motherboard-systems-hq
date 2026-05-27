/**
 * Deterministic grant resolver (Phase 45).
 *
 * Inputs supported (best-effort):
 * - { action_id, context?, meta?, policy?, ... }
 * - { args: [firstArg, ...], legacy_decision?, ... }  (wrapper buildGrantInput form)
 *
 * Grant sources (deterministic):
 * - MB_GRANTS_JSON env var (JSON string)
 * - policy/grants.json at repo root (if present)
 *
 * Minimal semantics:
 * - A grant "allows" if:
 *   - action_id startsWith any prefix in grant.allow_actions (strings)
 *   - AND (optional) scope constraints pass:
 *       - if scope/scope_id provided, context[scope] === scope_id OR context[scope+"_id"] === scope_id
 *       - if single_use true, still returns allow=true but includes single_use=true (enforcement elsewhere)
 */

import fs from "node:fs";
import path from "node:path";

function safeJsonParse(s, label) {
  try {
    return JSON.parse(s);
  } catch (e) {
    throw new Error(`Invalid JSON in ${label}: ${String(e?.message || e)}`);
  }
}

function loadGrantsFromEnv() {
  const raw = process.env.MB_GRANTS_JSON;
  if (!raw || !raw.trim()) return null;
  const parsed = safeJsonParse(raw, "MB_GRANTS_JSON");
  return parsed;
}

function loadGrantsFromFile(repoRoot) {
  const p = path.join(repoRoot, "policy", "grants.json");
  if (!fs.existsSync(p)) return null;
  const raw = fs.readFileSync(p, "utf8").trim();
  if (!raw) return null;
  return safeJsonParse(raw, p);
}

function normalizeGrants(x) {
  if (!x) return [];
  if (Array.isArray(x)) return x;
  if (typeof x === "object" && Array.isArray(x.grants)) return x.grants;
  return [];
}

function extractActionId(input) {
  if (input && typeof input === "object") {
    if (typeof input.action_id === "string" && input.action_id.trim()) return input.action_id.trim();
    if (typeof input.actionId === "string" && input.actionId.trim()) return input.actionId.trim();
    if (typeof input.action === "string" && input.action.trim()) return input.action.trim();

    const a0 = Array.isArray(input.args) ? input.args[0] : null;
    if (a0 && typeof a0 === "object") {
      if (typeof a0.action_id === "string" && a0.action_id.trim()) return a0.action_id.trim();
      if (typeof a0.actionId === "string" && a0.actionId.trim()) return a0.actionId.trim();
      if (typeof a0.action === "string" && a0.action.trim()) return a0.action.trim();
    }
  }
  return "";
}

function extractContext(input) {
  if (input && typeof input === "object") {
    if (input.context && typeof input.context === "object") return input.context;
    const a0 = Array.isArray(input.args) ? input.args[0] : null;
    if (a0 && typeof a0 === "object" && a0.context && typeof a0.context === "object") return a0.context;
  }
  return {};
}

function nowIso() {
  // deterministic-by-input is preferred, but time is only used for expires_at comparisons;
  // if you want strict determinism across time, keep expires_at far in the future in tests.
  return new Date().toISOString();
}

function isExpired(grant) {
  const exp = grant?.expires_at;
  if (!exp || typeof exp !== "string") return false;
  const t = Date.parse(exp);
  if (!Number.isFinite(t)) return false;
  return Date.parse(nowIso()) > t;
}

function scopePasses(grant, ctx) {
  const scope = grant?.scope;
  const scope_id = grant?.scope_id;
  if (!scope || !scope_id) return true;

  const v1 = ctx?.[scope];
  const v2 = ctx?.[`${scope}_id`];
  return (typeof v1 === "string" && v1 === scope_id) || (typeof v2 === "string" && v2 === scope_id);
}

function actionAllowedByGrant(grant, action_id) {
  const allow = grant?.allow_actions;
  if (!Array.isArray(allow)) return false;
  for (const p of allow) {
    if (typeof p === "string" && p.length > 0 && action_id.startsWith(p)) return true;
  }
  return false;
}

export async function resolvePolicyGrant(input) {
  const action_id = extractActionId(input);
  const context = extractContext(input);

  if (!action_id) {
    return {
      allow: false,
      applies: false,
      reason: "missing_action_id",
      matched_grant_id: null,
    };
  }

  const repoRoot = process.cwd();
  const src = loadGrantsFromEnv() ?? loadGrantsFromFile(repoRoot);
  const grants = normalizeGrants(src);

  for (const g of grants) {
    if (!g || typeof g !== "object") continue;
    if (isExpired(g)) continue;
    if (!scopePasses(g, context)) continue;
    if (!actionAllowedByGrant(g, action_id)) continue;

    return {
      allow: true,
      applies: true,
      matched_grant_id: g.id ?? null,
      single_use: !!g.single_use,
      scope: g.scope ?? null,
      scope_id: g.scope_id ?? null,
      notes: g.notes ?? null,
    };
  }

  return {
    allow: false,
    applies: false,
    reason: "no_matching_grant",
    matched_grant_id: null,
  };
}

export default resolvePolicyGrant;
