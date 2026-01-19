-- Phase30 canonical contract check (read-only)
-- Fails if required columns for "canonical-ready" mode are missing.
do $$
begin
  if not exists (select 1 from information_schema.columns where table_name='tasks' and column_name='payload') then
    raise exception 'missing tasks.payload';
  end if;
  if not exists (select 1 from information_schema.columns where table_name='tasks' and column_name='attempts') then
    raise exception 'missing tasks.attempts';
  end if;
  if not exists (select 1 from information_schema.columns where table_name='tasks' and column_name='next_run_at') then
    raise exception 'missing tasks.next_run_at';
  end if;
  if not exists (select 1 from information_schema.columns where table_name='task_events' and column_name='payload_jsonb') then
    raise exception 'missing task_events.payload_jsonb';
  end if;
end $$;
