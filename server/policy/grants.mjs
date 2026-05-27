import fs from 'node:fs';
import path from 'node:path';

function parseJsonOrThrow(raw, label) {
  const trimmed = String(raw || '').trim();
  if (!trimmed) return null;
  try {
    return JSON.parse(trimmed);
  } catch (e) {
    throw new Error(`invalid JSON in ${label}: ${e.message}`);
  }
}

function loadGrantsFromEnv() {
  const raw = process.env.MB_GRANTS_JSON;
  if (!raw) return null;
  return parseJsonOrThrow(raw, 'MB_GRANTS_JSON');
}

function loadGrantsFromFile(repoRoot) {
  const p = path.join(repoRoot, 'policy', 'grants.json');
  if (!fs.existsSync(p)) return null;
  const raw = fs.readFileSync(p, 'utf8');
  return parseJsonOrThrow(raw, p);
}

/**
 * Loads grants from env (preferred) or policy/grants.json (gitignored).
 * Returns: { grants: [...] } or { grants: [] }.
 */
export function loadGrants(repoRoot) {
  const fromEnv = loadGrantsFromEnv();
  if (fromEnv) return normalizeGrants(fromEnv);
  const fromFile = loadGrantsFromFile(repoRoot);
  if (fromFile) return normalizeGrants(fromFile);
  return { grants: [] };
}

function normalizeGrants(doc) {
  const grants = Array.isArray(doc?.grants) ? doc.grants : [];
  return { grants: grants.map(g => ({ ...g })) };
}

function matchesAction(action_id, allow_actions) {
  for (const a of allow_actions || []) {
    if (typeof a !== 'string') continue;
    if (a.endsWith('.')) {
      if (action_id.startsWith(a)) return true;
    } else {
      if (action_id === a) return true;
    }
  }
  return false;
}

function parseRfc3339ToMs(s) {
  const t = Date.parse(s);
  if (!Number.isFinite(t)) return null;
  return t;
}

/**
 * Validate if there exists a grant authorizing this action in this scope.
 * Inputs:
 * - action_id
 * - meta: { run_id?, task_id? }
 * - now_ms: injected for determinism in tests; default Date.now() in callers/harnesses
 *
 * Returns:
 * - { ok: boolean, grant: object|null, reason: string }
 */
export function findValidGrant({ grants }, { action_id, meta = {}, now_ms }) {
  const now = Number.isFinite(now_ms) ? now_ms : Date.now();

  for (const g of grants || []) {
    if (!g || typeof g !== 'object') continue;
    const id = g.id;

    if (!matchesAction(action_id, g.allow_actions)) continue;

    const scope = g.scope;
    const scope_id = g.scope_id;

    if (scope !== 'run_id' && scope !== 'task_id') continue;
    if (typeof scope_id !== 'string' || !scope_id) continue;

    const actual = scope === 'run_id' ? meta.run_id : meta.task_id;
    if (actual !== scope_id) continue;

    // expiry
    if (typeof g.expires_at === 'string') {
      const exp = parseRfc3339ToMs(g.expires_at);
      if (exp === null) continue;
      if (now > exp) continue;
    } else {
      // If no expires_at, reject in v1 (fail-safe)
      continue;
    }

    return { ok: true, grant: g, reason: `matched:${id || 'unknown'}` };
  }

  return { ok: false, grant: null, reason: 'no_valid_grant' };
}
