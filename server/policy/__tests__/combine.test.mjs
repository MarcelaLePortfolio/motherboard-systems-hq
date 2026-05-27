import assert from 'node:assert/strict';
import { combinePolicyWithGrant } from '../combine.mjs';

{
  const { final, audit } = combinePolicyWithGrant(
    { action_id: 'x', tier: 'A', decision: 'allow', policy_rule_id: 'r1', trace: { policy_version: 1 } },
    { grant_ok: true, grant: { id: 'g1' } }
  );
  assert.equal(final.decision, 'allow');
  assert.equal(audit, null);
}

{
  const { final, audit } = combinePolicyWithGrant(
    { action_id: 'task.mutate.file', tier: 'B', decision: 'deny', policy_rule_id: 'r2', trace: { policy_version: 1 } },
    { grant_ok: true, grant: { id: 'g1', scope: 'run_id', scope_id: 'r1', expires_at: '2099-01-01T00:00:00Z' } }
  );
  assert.equal(final.decision, 'allow_with_conditions');
  assert.ok(typeof audit === 'string' && audit.includes('"policy.grant_used"'));
}

{
  const { final, audit } = combinePolicyWithGrant(
    { action_id: 'danger', tier: 'C', decision: 'deny', policy_rule_id: 'r3', trace: { policy_version: 1 } },
    { grant_ok: true, grant: { id: 'g1' } }
  );
  assert.equal(final.decision, 'deny');
  assert.equal(audit, null);
}
