-- Phase 39: action_tier policy mapping (SQL-only, declarative)
-- This file intentionally contains no writes and no DDL.

-- Policy: map task/event "kind" (string) -> action_tier.
-- Unknown kinds are treated as TIER_C (fail-closed) by validation/smoke.

WITH policy(kind, action_tier, reason) AS (
  VALUES
    -- ---------------------------
    -- TIER_A (read-only / observe)
    -- ---------------------------
    ('task.created',   'TIER_A', 'event: creation observed'),
    ('task.running',   'TIER_A', 'event: running observed'),
    ('task.completed', 'TIER_A', 'event: completion observed'),
    ('task.failed',    'TIER_A', 'event: failure observed'),
    ('task.canceled',  'TIER_A', 'event: cancel observed'),
    ('task.cancelled', 'TIER_A', 'event: cancel observed'),

    -- legacy / normalized aliases observed in DB
    ('completed',      'TIER_A', 'legacy alias for completion observed'),

    -- ---------------------------
    -- TIER_B (internal mutations)
    -- ---------------------------
    ('task.started',   'TIER_B', 'internal: start transition'),
    ('heartbeat',      'TIER_B', 'internal: heartbeat/lease freshness'),

    -- ---------------------------
    -- TIER_C (external side effects)
    -- ---------------------------
    -- Keep explicit, add only when such kinds exist:
    -- ('task.email.send',   'TIER_C', 'external: email side effect'),
    -- ('task.webhook.call', 'TIER_C', 'external: network side effect')

    ('__POLICY_SENTINEL__', 'TIER_A', 'sentinel: ensures VALUES is never empty')
)
SELECT kind, action_tier, reason
FROM policy
WHERE kind <> '__POLICY_SENTINEL__';
