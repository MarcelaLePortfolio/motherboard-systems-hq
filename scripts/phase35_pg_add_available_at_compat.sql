-- Phase35: compat-only column required by older worker claim SQL.
ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS available_at timestamptz;
