import assert from 'node:assert/strict';
import process from 'node:process';
import { loadDefaultPolicyFromRepoRoot, evaluatePolicy } from '../evaluate.mjs';

const repoRoot = process.cwd();
const { policy, path } = loadDefaultPolicyFromRepoRoot(repoRoot);

assert.ok(policy && typeof policy === 'object');
assert.ok(path.endsWith('policy/value_policy.json'));

{
  const r = evaluatePolicy({ action_id: 'unknown.action', context: {} }, { policy });
  assert.equal(r.tier, 'B');
  assert.equal(r.decision, 'deny');
}
