import process from 'node:process';
import { loadDefaultPolicyFromRepoRoot, evaluatePolicy } from '../server/policy/evaluate.mjs';
import { loadGrants, findValidGrant } from '../server/policy/grants.mjs';
import { combinePolicyWithGrant } from '../server/policy/combine.mjs';

const repoRoot = process.cwd();
const { policy } = loadDefaultPolicyFromRepoRoot(repoRoot);
const grantsDoc = loadGrants(repoRoot);

const req = { action_id: 'task.mutate.file', context: {}, meta: { run_id: 'run_123' } };
const pol = evaluatePolicy(req, { policy });

const gv = findValidGrant(grantsDoc, { action_id: req.action_id, meta: req.meta, now_ms: Date.now() });
const { final, audit } = combinePolicyWithGrant(
  { action_id: req.action_id, tier: pol.tier, decision: pol.decision, policy_rule_id: pol.rule_id, trace: pol.trace },
  { grant_ok: gv.ok, grant: gv.grant }
);

console.log(JSON.stringify({ policy: { tier: pol.tier, decision: pol.decision, rule_id: pol.rule_id }, grant_ok: gv.ok, final, audit }, null, 2));
