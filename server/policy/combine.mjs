import { stableStringify } from './stable_json.mjs';

const DECISIONS = new Set(['allow', 'deny', 'allow_with_conditions']);
const TIERS = new Set(['A', 'B', 'C']);

/**
 * Pure combiner:
 * - policy allow => allow
 * - policy deny:
 *   - Tier B may become allow_with_conditions if grant_ok
 *   - Tier C remains deny always (Option A cannot lift Tier C)
 *
 * Returns:
 * - final: { tier, decision }
 * - audit: null OR a stable JSON string (single-line) describing the grant usage
 */
export function combinePolicyWithGrant({ action_id, tier, decision, policy_rule_id, trace }, { grant_ok, grant }) {
  if (!TIERS.has(tier)) throw new Error(`invalid tier: ${tier}`);
  if (!DECISIONS.has(decision)) throw new Error(`invalid decision: ${decision}`);

  if (decision === 'allow') {
    return { final: { tier, decision: 'allow' }, audit: null };
  }

  // deny path
  if (tier === 'C') {
    return { final: { tier, decision: 'deny' }, audit: null };
  }

  if (tier === 'B' && grant_ok) {
    const auditObj = {
      kind: 'policy.grant_used',
      action_id,
      tier,
      policy_rule_id: policy_rule_id ?? null,
      grant_id: grant?.id ?? null,
      scope: grant?.scope ?? null,
      scope_id: grant?.scope_id ?? null,
      expires_at: grant?.expires_at ?? null,
      result_decision: 'allow_with_conditions',
      policy_version: trace?.policy_version ?? null
    };
    return {
      final: { tier, decision: 'allow_with_conditions' },
      audit: stableStringify(auditObj)
    };
  }

  return { final: { tier, decision: 'deny' }, audit: null };
}
