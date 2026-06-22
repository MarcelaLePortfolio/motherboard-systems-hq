
#!/usr/bin/env bash

set -euo pipefail

echo "===== APPLY TASK MUTATION SCHEMA MIGRATION ====="

docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d postgres << 'SQL'

alter table tasks add column if not exists notes text;

alter table tasks add column if not exists run_id text;

alter table tasks add column if not exists action_tier text default 'A';

alter table tasks add column if not exists kind text;

alter table tasks add column if not exists payload jsonb default '{}'::jsonb;

SQL

echo

echo "===== VERIFY TASKS TABLE ====="

docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d postgres -c "\d+ tasks"

echo

echo "===== RERUN TASK MUTATION SMOKE ====="

./smoke-current-task-mutations.sh

