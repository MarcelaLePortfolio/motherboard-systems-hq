import fs from 'node:fs';
import path from 'node:path';

const DECISIONS = new Set(['allow', 'deny', 'allow_with_conditions']);
const TIERS = new Set(['A', 'B', 'C']);

function stableKeyList(obj) {
  return Object.keys(obj).sort();
}

function stableTrace(trace) {
  // Ensure stable ordering for trace arrays
  if (Array.isArray(trace.reasons)) trace.reasons = [...trace.reasons].sort();
  if (Array.isArray(trace.conditions)) {
    trace.conditions = [...trace.conditions].sort((a, b) => String(a.id).localeCompare(String(b.id)));
  }
  return trace;
}

function loadJsonPolicyFile(policyPath) {
  const raw = fs.readFileSync(policyPath, 'utf8');
  const trimmed = raw.trim();
  if (!trimmed.startsWith('{')) throw new Error(`policy must be JSON: ${policyPath}`);
  return JSON.parse(trimmed);
}

/**
 * Pure, deterministic evaluator.
 * NOTE: Reading policy from disk is handled elsewhere; this function does not perform IO.
 */
export function evaluatePolicy({ action_id, context = {}, meta = {} }, { policy }) {
  if (typeof action_id !== 'string' || !action_id.trim()) throw new Error('action_id must be a non-empty string');
  const canonical_action = action_id.trim();

  if (context && typeof context !== 'object') throw new Error('context must be an object');
  const ctx = context || {};

  // Reject obvious self-tier attempts (v1 hard reject)
  for (const k of Object.keys(ctx)) {
    if (k === 'tier' || k === 'requested_tier' || k === 'decision') {
      throw new Error(`forbidden context key: ${k}`);
    }
  }

  const policy_version = policy.policy_version ?? null;

  const defaults = policy.defaults || {};
  const defaultTier = defaults.unknown_action_tier || 'B';
  const defaultDecision = defaults.unknown_action_decision || 'deny';

  if (!TIERS.has(defaultTier)) throw new Error(`invalid default tier: ${defaultTier}`);
  if (!DECISIONS.has(defaultDecision)) throw new Error(`invalid default decision: ${defaultDecision}`);

  const trace = stableTrace({
    policy_version,
    matched: false,
    matched_rule_id: null,
    default_applied: true,
    reasons: [],
    conditions: [],
    normalized: {
      action_id: canonical_action,
      context_keys: stableKeyList(ctx),
      meta_keys: meta && typeof meta === 'object' ? stableKeyList(meta) : [],
    },
  });

  const rules = Array.isArray(policy.rules) ? policy.rules : [];
  for (const r of rules) {
    const match = r.match || {};
    const exact = match.action_id;
    const prefix = match.action_prefix;

    let ok = false;
    if (typeof exact === 'string' && exact === canonical_action) ok = true;
    if (!ok && typeof prefix === 'string' && canonical_action.startsWith(prefix)) ok = true;

    if (!ok) continue;

    const tier = r.tier;
    const decision = r.decision;
    if (!TIERS.has(tier)) throw new Error(`invalid tier in rule ${r.id}: ${tier}`);
    if (!DECISIONS.has(decision)) throw new Error(`invalid decision in rule ${r.id}: ${decision}`);

    trace.matched = true;
    trace.matched_rule_id = r.id || null;
    trace.default_applied = false;
    trace.reasons.push(`matched:${r.id || 'unknown'}`);
    stableTrace(trace);

    return {
      tier,
      decision,
      rule_id: r.id || null,
      trace,
    };
  }

  trace.reasons.push('no_rule_matched');
  stableTrace(trace);

  return {
    tier: defaultTier,
    decision: defaultDecision,
    rule_id: null,
    trace,
  };
}

export function loadDefaultPolicyFromRepoRoot(repoRoot) {
  const p = path.join(repoRoot, 'policy', 'value_policy.json');
  const policy = loadJsonPolicyFile(p);
  return { policy, path: p };
}
