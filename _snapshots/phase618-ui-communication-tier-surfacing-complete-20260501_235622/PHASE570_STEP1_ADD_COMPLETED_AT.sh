#!/bin/bash
set -e

echo "Adding schema-compatible completed_at column for Phase 32 completion SQL..."

docker compose exec postgres psql -U postgres -d postgres -c "
alter table tasks
add column if not exists completed_at timestamptz null;
"

docker compose exec postgres psql -U postgres -d postgres -c "
select column_name, data_type, is_nullable
from information_schema.columns
where table_name='tasks'
  and column_name='completed_at';
"

cat > PHASE570_COMPLETION_SCHEMA_COMPATIBILITY.txt << 'DOC'
PHASE 570 — COMPLETION SCHEMA COMPATIBILITY

Change:
- Added tasks.completed_at timestamptz null in runtime DB.

Reason:
- Existing Phase 32 success/failure SQL references completed_at.
- Completion lifecycle cannot safely run until schema supports that column.

Scope:
- DB schema compatibility only.
- No worker completion behavior added yet.
- No API mutation.
- No UI mutation.

Next Safe Objective:
- Wire worker completion using existing phase32_mark_success.sql only after this column is confirmed.
DOC

git add PHASE570_STEP1_ADD_COMPLETED_AT.sh PHASE570_COMPLETION_SCHEMA_COMPATIBILITY.txt
git commit -m "Phase 570: add completed_at schema compatibility documentation"
git push
