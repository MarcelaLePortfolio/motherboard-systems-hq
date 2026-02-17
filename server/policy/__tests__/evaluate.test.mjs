import assert from 'node:assert/strict';
import { evaluatePolicy } from '../evaluate.mjs';

function stableStringify(obj) {
  return JSON.stringify(obj, Object.keys(obj).sort());
}

const policy = {
  policy_version: 1,
  defaults: { unknown_action_tier: 'B', unknown_action_decision: 'deny' },
  rules: [
    { id: 'a1', match: { action_id: 'run.view' }, tier: 'A', decision: 'allow' },
    { id: 'a2', match: { action_prefix: 'task.mutate' }, tier: 'B', decision: 'deny' },
    { id: 'a3', match: { action_id: 'run.view' }, tier: 'B', decision: 'deny' }, // should never win (first-match)
  ],
};

{
  const r = evaluatePolicy({ action_id: 'unknown.action', context: {} }, { policy });
  assert.equal(r.tier, 'B');
  assert.equal(r.decision, 'deny');
  assert.equal(r.rule_id, null);
  assert.equal(r.trace.default_applied, true);
}

{
  const r = evaluatePolicy({ action_id: 'run.view', context: {} }, { policy });
  assert.equal(r.tier, 'A');
  assert.equal(r.decision, 'allow');
  assert.equal(r.rule_id, 'a1');
  assert.equal(r.trace.matched_rule_id, 'a1');
}

{
  const r = evaluatePolicy({ action_id: 'task.mutate.file', context: {} }, { policy });
  assert.equal(r.tier, 'B');
  assert.equal(r.decision, 'deny');
  assert.equal(r.rule_id, 'a2');
}

{
  const input = { action_id: 'run.view', context: { foo: 'bar' }, meta: { run_id: 'r1' } };
  const a = evaluatePolicy(input, { policy });
  const b = evaluatePolicy(input, { policy });
  assert.equal(stableStringify(a), stableStringify(b));
}

{
  assert.throws(
    () => evaluatePolicy({ action_id: 'run.view', context: { tier: 'A' } }, { policy }),
    /forbidden context key/
  );
}
