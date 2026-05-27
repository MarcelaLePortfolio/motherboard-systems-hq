import assert from 'node:assert/strict';
import { findValidGrant } from '../grants.mjs';

const grantsDoc = {
  grants: [
    {
      id: 'g1',
      allow_actions: ['task.mutate.'],
      scope: 'run_id',
      scope_id: 'run_1',
      expires_at: '2099-01-01T00:00:00Z',
      single_use: true
    },
    {
      id: 'g_expired',
      allow_actions: ['task.mutate.'],
      scope: 'run_id',
      scope_id: 'run_1',
      expires_at: '2000-01-01T00:00:00Z'
    }
  ]
};

{
  const r = findValidGrant(grantsDoc, { action_id: 'task.mutate.file', meta: { run_id: 'run_1' }, now_ms: Date.parse('2026-01-01T00:00:00Z') });
  assert.equal(r.ok, true);
  assert.equal(r.grant.id, 'g1');
}

{
  const r = findValidGrant(grantsDoc, { action_id: 'task.mutate.file', meta: { run_id: 'run_X' }, now_ms: Date.parse('2026-01-01T00:00:00Z') });
  assert.equal(r.ok, false);
}

{
  const r = findValidGrant(grantsDoc, { action_id: 'task.mutate.file', meta: { run_id: 'run_1' }, now_ms: Date.parse('2026-01-01T00:00:00Z') });
  assert.equal(r.grant.id, 'g1');
  assert.notEqual(r.grant.id, 'g_expired');
}

{
  const r = findValidGrant(grantsDoc, { action_id: 'run.view', meta: { run_id: 'run_1' }, now_ms: Date.parse('2026-01-01T00:00:00Z') });
  assert.equal(r.ok, false);
}
