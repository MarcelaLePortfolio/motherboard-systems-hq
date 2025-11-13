ALTER TABLE task_events ADD COLUMN type TEXT DEFAULT 'unknown';
ALTER TABLE task_events ADD COLUMN payload TEXT DEFAULT '';
ALTER TABLE task_events ADD COLUMN result TEXT DEFAULT '';
