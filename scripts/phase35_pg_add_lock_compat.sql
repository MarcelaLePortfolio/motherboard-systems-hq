-- Phase35: compat-only columns required by phase28 claim SQL.
ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS locked_by text,
  ADD COLUMN IF NOT EXISTS lock_expires_at timestamptz;
