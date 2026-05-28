
#!/usr/bin/env bash

set -euo pipefail

REPORT="TASK_MUTATION_SCHEMA_MIGRATION_V2.txt"

{

  echo "===== APPLY TASK MUTATION SCHEMA MIGRATION V2 ====="

  date

  echo

  echo "===== BEFORE ====="

  docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d postgres -c "\d+ tasks"

  echo

  echo "===== ALTER TABLE TASKS ====="

  docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c "alter table public.tasks add column if not exists notes text;"

  docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c "alter table public.tasks add column if not exists run_id text;"

  docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c "alter table public.tasks add column if not exists action_tier text default 'A';"

  docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c "alter table public.tasks add column if not exists kind text;"

  docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c "alter table public.tasks add column if not exists payload jsonb default '{}'::jsonb;"

  echo

  echo "===== AFTER ====="

  docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d postgres -c "\d+ tasks"

  echo

  echo "===== COLUMN ASSERTION ====="

  docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d postgres -c "select column_name, data_type from information_schema.columns where table_schema='public' and table_name='tasks' and column_name in ('notes','run_id','action_tier','kind','payload') order by column_name;"

  echo

  echo "===== RERUN TASK MUTATION SMOKE ====="

  ./smoke-current-task-mutations.sh

} | tee "$REPORT"

git add migrate-task-mutation-schema-v2.sh smoke-current-task-mutations.sh "$REPORT"

git commit -m "Migrate task mutation schema after runtime restore"

git push

