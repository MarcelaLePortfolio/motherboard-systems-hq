-- Phase 39: action_tier policy mapping (SQL-only, declarative)
-- This file intentionally contains no writes and no DDL.

-- Policy: map task "kind" (string) -> action_tier.
-- Update this mapping as new kinds appear.
-- Fail-closed rule is implemented in the validation query (unknown -> TIER_C).

WITH policy(kind, action_tier, reason) AS (
  VALUES
    -- ---------------------------
    -- TIER_A (read-only / observe)
    -- ---------------------------
    ('task.created',   'TIER_A', 'event: creation observed (read-only mapping)'),
    ('task.running',   'TIER_A', 'event: running observed (read-only mapping)'),
    ('task.completed', 'TIER_A', 'event: completion observed (read-only mapping)'),
    ('task.failed',    'TIER_A', 'event: failure observed (read-only mapping)'),
    ('task.canceled',  'TIER_A', 'event: cancel observed (read-only mapping)'),
    ('task.cancelled', 'TIER_A', 'event: cancel observed (read-only mapping)'),

    -- ---------------------------
    -- TIER_B (internal mutations)
    -- ---------------------------
    -- Example placeholders (enable only when those kinds exist):
    -- ('task.retry.requested', 'TIER_B', 'internal: retry scheduling'),
    -- ('task.reclaimed',       'TIER_B', 'internal: lease reclaim'),

    -- ---------------------------
    -- TIER_C (external side effects)
    -- ---------------------------
    -- Example placeholders (enable only when those kinds exist):
    -- ('task.email.send',      'TIER_C', 'external: email side effect'),
    -- ('task.webhook.call',    'TIER_C', 'external: network side effect')

    -- Keep this list minimal and deliberate.
    ('__POLICY_SENTINEL__', 'TIER_A', 'sentinel: ensures VALUES is never empty')
)
SELECT kind, action_tier, reason
FROM policy
WHERE kind <> '__POLICY_SENTINEL__';
