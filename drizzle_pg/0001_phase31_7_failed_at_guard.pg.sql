-- phase31.7: enforce failed_at ↔ status invariant at DB layer
create or replace function tasks_failed_at_guard()
returns trigger as $$
begin
  if new.status = 'failed' then
    if new.failed_at is null then
      new.failed_at := now();
    end if;
  else
    new.failed_at := null;
  end if;
  return new;
end;
$$ language plpgsql;
drop trigger if exists trg_tasks_failed_at_guard on tasks;
create trigger trg_tasks_failed_at_guard
before insert or update on tasks
for each row execute function tasks_failed_at_guard();
alter table tasks
drop constraint if exists tasks_failed_at_matches_status;
alter table tasks
add constraint tasks_failed_at_matches_status
check (
  (status = 'failed' and failed_at is not null)
  or
  (status <> 'failed' and failed_at is null)
);
