-- Phase 45: auditable policy_grants (override authority model)
-- Deterministic + auditable override authority surface.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS policy_grants (
  grant_id     uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  created_at   timestamptz NOT NULL DEFAULT now(),
  created_by   text        NOT NULL,

  subject      text        NOT NULL,
  scope        text        NOT NULL,

  decision     text        NOT NULL CHECK (decision IN ('allow','deny')),
  reason       text        NOT NULL,

  expires_at   timestamptz NULL,
  metadata     jsonb       NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS policy_grants_subject_scope_idx
  ON policy_grants (subject, scope);

CREATE INDEX IF NOT EXISTS policy_grants_subject_scope_decision_idx
  ON policy_grants (subject, scope, decision);

CREATE INDEX IF NOT EXISTS policy_grants_expires_at_idx
  ON policy_grants (expires_at);

CREATE OR REPLACE VIEW policy_grants_active AS
SELECT *
FROM policy_grants
WHERE expires_at IS NULL OR expires_at > now();

COMMIT;
