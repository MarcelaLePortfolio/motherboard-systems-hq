import assert from 'node:assert/strict';
import process from 'node:process';
import { loadDefaultPolicyFromRepoRoot, evaluatePolicy } from '../evaluate.mjs';
import { stableStringify } from '../stable_json.mjs';

const repoRoot = process.cwd();
const { policy } = loadDefaultPolicyFromRepoRoot(repoRoot);

const input = {
  action_id: 'run.view',
  context: { z: 2, a: 1, nested: { b: 2, a: 1 } },
  meta: { epoch: 7, run_id: 'r1' },
};

const r1 = evaluatePolicy(input, { policy });
const r2 = evaluatePolicy(input, { policy });

assert.equal(stableStringify(r1), stableStringify(r2));

// Ensure trace is stable under stableStringify (i.e., no random ordering)
assert.ok(r1.trace && typeof r1.trace === 'object');
assert.equal(stableStringify(r1.trace), stableStringify(r2.trace));
