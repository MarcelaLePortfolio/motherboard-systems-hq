-- Phase 19: ensure task_events exists (idempotent)
create extension if not exists "pgcrypto";

create table if not exists "task_events" (
  "id" uuid primary key default gen_random_uuid(),
  "kind" text not null,
  "payload" jsonb not null,
  "created_at" timestamptz not null default now()
);

-- Guard: Phase 36 run_view expects task_events.ts (epoch ms) to exist.
-- Safe on fresh boot + idempotent on re-run.
ALTER TABLE public.task_events
  ADD COLUMN IF NOT EXISTS ts BIGINT;
