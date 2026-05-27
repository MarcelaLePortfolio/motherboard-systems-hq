# Phase 19 — Postgres task_events Baseline (Next Steps)

Current verified baseline:
- docker compose services: postgres + dashboard
- Postgres tables present: public.tasks, public.task_events
- task_events shape (current reality in Postgres):
  - id bigserial primary key
  - kind text not null
  - payload text not null
  - created_at text default now()::text
- Working scripts:
  - scripts/phase19_export_postgres_env.sh (eval to set DATABASE_URL/POSTGRES_URL)
  - scripts/phase19_tasks_postgres_doctor.sh
  - scripts/phase19_task_events_smoke.cjs
  - scripts/phase19_postgres_apply_task_events.sql
  - scripts/phase19_apply_postgres_sql_via_container.sh

Immediate next work (pick in this order):
1) **Codify schema ownership**
   - Drizzle migrations currently include a sqlite-style `CREATE TABLE ... AUTOINCREMENT` in `drizzle/0000_safe_kylun.sql`.
   - Postgres “source of truth” is now `scripts/phase19_postgres_apply_task_events.sql`.
   - Decision: either (A) split Drizzle configs (sqlite vs postgres), or (B) stop using Drizzle migrations for Postgres and keep SQL apply scripts for Postgres.

2) **Minimal app-level write → read**
   - Add a tiny Node script in `scripts/` that:
     - uses DATABASE_URL/POSTGRES_URL
     - inserts (`kind='app-smoke'`, `payload='{"ok":true,...}'`)
     - reads back the inserted row + latest 5
   - This proves the repo can write/read Postgres without psql.

3) **Integrate task_events into Task lifecycle**
   - Wherever tasks are created/updated (server route or worker), append task_events rows:
     - kind: 'task.created' | 'task.updated' | 'task.completed' | 'task.failed'
     - payload: JSON string describing task_id + delta + ts
   - Keep it minimal: one write on create + one write on status transition.

4) **Persist env for local dev**
   - Option: add a documented `source scripts/phase19_export_postgres_env.sh` / `eval "$(…)"` step to any Phase 19 resume script.

Golden tags:
- v19.5-phase19-postgres-task_events-smoke-ok
- v19.6-phase19-postgres-env-helper-ok
