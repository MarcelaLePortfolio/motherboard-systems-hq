-- Phase 57.1 — CI/demo hardening: align tasks schema with probe writer
-- CI snapshot smoke exercises /api/policy/probe which upserts into tasks(..., title, ...).
-- Some fresh PG boots may have tasks without title; make it idempotent and safe.

ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS title TEXT;
