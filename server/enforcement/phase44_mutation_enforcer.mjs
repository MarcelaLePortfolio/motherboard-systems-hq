import { REASON } from "./phase44_reason_codes.mjs";
import { MUTATION_ALLOWLIST } from "./phase44_mutation_allowlist.mjs";

/**
 * ENFORCEMENT_MODE:
 * - "off"    : no-op
 * - "shadow" : log would-block decisions, but allow request
 * - "enforce": block non-allowlisted mutation routes
 */
export function getEnforcementMode(env = process.env) {
  const raw = (env.ENFORCEMENT_MODE || "off").toLowerCase().trim();
  if (raw === "off" || raw === "shadow" || raw === "enforce") return raw;
  return "off";
}

function isMutationMethod(method) {
  return method === "POST" || method === "PUT" || method === "PATCH" || method === "DELETE";
}

function escapeRegex(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

/**
 * Convert a limited Express-style path pattern into a RegExp:
 * - "/api/tasks/:id/cancel" => /^\/api\/tasks\/[^/]+\/cancel$/
 * - "/api/tasks" => /^\/api\/tasks$/
 */
function compileExpressPathPattern(pathPattern) {
  if (typeof pathPattern !== "string" || !pathPattern.startsWith("/")) {
    // Defensive: compile to never-match
    return /^$/;
  }

  const parts = pathPattern.split("/").filter(Boolean).map((seg) => {
    if (seg.startsWith(":") && seg.length > 1) return "[^/]+";
    return escapeRegex(seg);
  });

  return new RegExp("^/" + parts.join("/") + "$");
}

function buildAllowlistIndex(entries) {
  const idx = new Map(); // method -> [{ path, re }]
  for (const e of entries || []) {
    if (!e || typeof e !== "object") continue;
    const method = String(e.method || "").toUpperCase().trim();
    const path = String(e.path || "").trim();
    if (!isMutationMethod(method)) continue;
    if (!path.startsWith("/")) continue;

    const re = compileExpressPathPattern(path);
    const arr = idx.get(method) || [];
    arr.push({ path, re });
    idx.set(method, arr);
  }
  return idx;
}

function isAllowlisted(idx, method, path) {
  const arr = idx.get(method);
  if (!arr || arr.length === 0) return false;
  for (const ent of arr) {
    if (ent.re.test(path)) return true;
  }
  return false;
}

function jsonError(res, status, payload) {
  // Deterministic JSON error envelope (no stack traces).
  res.status(status).json(payload);
}

export function createMutationEnforcementMiddleware(opts = {}) {
  const mode = (opts.mode || getEnforcementMode(opts.env || process.env)).toLowerCase();
  const logger = opts.logger || console;

  const allowlist = Array.isArray(opts.allowlist) ? opts.allowlist : MUTATION_ALLOWLIST;
  const idx = buildAllowlistIndex(allowlist);

  return function phase44MutationEnforcer(req, res, next) {
    try {
      const m = String(req.method || "").toUpperCase();
      if (!isMutationMethod(m)) return next();

      // Scope boundary: server HTTP mutation routes only.
      // Match against req.path (no query).
      const path = req.path || req.url || "";

      if (mode === "off") return next();

      const ok = isAllowlisted(idx, m, path);

      if (ok) return next();

      const decision = {
        ok: false,
        reason_code: REASON.E_MUTATION_NOT_ALLOWLISTED,
        enforcement_mode: mode,
        method: m,
        path,
      };

      if (mode === "shadow") {
        // Allow but log deterministically.
        try {
          logger.warn("[phase44] mutation_route_shadow", decision);
        } catch (_) {
          // ignore logger failures
        }
        return next();
      }

      // enforce
      try {
        logger.error("[phase44] mutation_route_blocked", decision);
      } catch (_) {
        // ignore logger failures
      }
      return jsonError(res, 403, decision);
    } catch (err) {
      const mode2 = mode === "enforce" ? "enforce" : "shadow";
      const decision = {
        ok: false,
        reason_code: REASON.E_INTERNAL_ERROR,
        enforcement_mode: mode2,
      };

      if (mode === "enforce") return jsonError(res, 500, decision);

      try {
        logger.warn("[phase44] mutation_route_internal_error_shadow", decision);
      } catch (_) {}
      return next();
    }
  };
}
