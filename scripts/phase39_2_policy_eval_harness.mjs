import path from 'node:path';
import process from 'node:process';
import { loadDefaultPolicyFromRepoRoot, evaluatePolicy } from '../server/policy/evaluate.mjs';

function die(msg) {
  console.error(msg);
  process.exit(2);
}

const repoRoot = process.cwd();
const { policy, path: policyPath } = loadDefaultPolicyFromRepoRoot(repoRoot);

if (!policy || typeof policy !== 'object') die('policy load failed: not an object');
if (!policy.policy_version) die('policy missing policy_version');

const cases = [
  { name: 'unknown denies', req: { action_id: 'unknown.action', context: {}, meta: {} }, want: { tier: 'B', decision: 'deny' } },
  { name: 'run.view allows', req: { action_id: 'run.view', context: {}, meta: { run_id: 'r1' } }, want: { tier: 'A', decision: 'allow' } },
  { name: 'task.mutate prefix denies', req: { action_id: 'task.mutate.file', context: {}, meta: { task_id: 't1' } }, want: { tier: 'B', decision: 'deny' } },
];

for (const c of cases) {
  const r = evaluatePolicy(c.req, { policy });
  if (r.tier !== c.want.tier || r.decision !== c.want.decision) {
    die(`case failed: ${c.name}\n  got=${JSON.stringify({ tier: r.tier, decision: r.decision, rule_id: r.rule_id })}\n  want=${JSON.stringify(c.want)}`);
  }
}

console.log(JSON.stringify({
  ok: true,
  policy_path: path.relative(repoRoot, policyPath),
  policy_version: policy.policy_version,
  cases: cases.map(c => c.name),
}, null, 2));
