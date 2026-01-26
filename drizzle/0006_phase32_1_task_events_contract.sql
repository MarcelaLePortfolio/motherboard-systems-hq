BEGIN;
-- 1) Normalize task_events.task_id: if numeric tasks.id, rewrite to tasks.task_id ("tN")
CREATE OR REPLACE FUNCTION task_events_normalize_task_id()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  ext_id text;
BEGIN
  IF NEW.task_id IS NOT NULL AND NEW.task_id ~ '^[0-9]+$' THEN
    SELECT t.task_id INTO ext_id
    FROM tasks t
    WHERE t.id = NEW.task_id::bigint;

    IF ext_id IS NOT NULL THEN
      NEW.task_id := ext_id;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_task_events_normalize_task_id ON task_events;
CREATE TRIGGER trg_task_events_normalize_task_id
BEFORE INSERT ON task_events
FOR EACH ROW
EXECUTE FUNCTION task_events_normalize_task_id();
-- 2) Normalize payload.task_id similarly (payload is TEXT but contains JSON)
CREATE OR REPLACE FUNCTION task_events_normalize_payload_task_id()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  j jsonb;
  tid_text text;
  ext_id text;
BEGIN
  BEGIN
    j := NEW.payload::jsonb;
  EXCEPTION WHEN others THEN
    RETURN NEW;
  END;
  tid_text := NULLIF(j->>'task_id','');
  IF tid_text IS NOT NULL AND tid_text ~ '^[0-9]+$' THEN
    SELECT t.task_id INTO ext_id
    FROM tasks t
    WHERE t.id = tid_text::bigint;

    IF ext_id IS NOT NULL THEN
      j := jsonb_set(j, '{task_id}', to_jsonb(ext_id), true);
      NEW.payload := j::text;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_task_events_normalize_payload_task_id ON task_events;
CREATE TRIGGER trg_task_events_normalize_payload_task_id
BEFORE INSERT ON task_events
FOR EACH ROW
EXECUTE FUNCTION task_events_normalize_payload_task_id();
-- 3) Extract run_id/actor from payload into columns (worker emits them in JSON)
CREATE OR REPLACE FUNCTION task_events_extract_run_actor()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  j jsonb;
BEGIN
  BEGIN
    j := NEW.payload::jsonb;
  EXCEPTION WHEN others THEN
    RETURN NEW;
  END;
  IF NEW.run_id IS NULL THEN
    NEW.run_id := NULLIF(j->>'run_id','');
  END IF;
  IF NEW.actor IS NULL THEN
    NEW.actor := NULLIF(j->>'actor','');
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_task_events_extract_run_actor ON task_events;
CREATE TRIGGER trg_task_events_extract_run_actor
BEFORE INSERT ON task_events
FOR EACH ROW
EXECUTE FUNCTION task_events_extract_run_actor();
-- 4) Helpful indexes
CREATE INDEX IF NOT EXISTS task_events_task_id_id_desc_idx
  ON task_events (task_id, id DESC);
CREATE INDEX IF NOT EXISTS task_events_run_id_id_desc_idx
  ON task_events (run_id, id DESC);
CREATE INDEX IF NOT EXISTS task_events_actor_id_desc_idx
  ON task_events (actor, id DESC);
-- 5) Contract constraints
ALTER TABLE task_events
  DROP CONSTRAINT IF EXISTS task_events_task_id_not_numeric;
ALTER TABLE task_events
  ADD CONSTRAINT task_events_task_id_not_numeric
  CHECK (task_id IS NULL OR task_id !~ '^[0-9]+$');
ALTER TABLE task_events
  DROP CONSTRAINT IF EXISTS task_events_run_id_required_for_non_created;
ALTER TABLE task_events
  ADD CONSTRAINT task_events_run_id_required_for_non_created
  CHECK (kind = 'task.created' OR run_id IS NOT NULL);
ALTER TABLE task_events
  DROP CONSTRAINT IF EXISTS task_events_actor_required;
ALTER TABLE task_events
  ADD CONSTRAINT task_events_actor_required
  CHECK (actor IS NOT NULL AND actor <> '');
COMMIT;
