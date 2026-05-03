#!/bin/bash
set -e

echo "Adding success-only completion path to worker..."

python3 - << 'PY'
from pathlib import Path

path = Path("server/worker/phase26_task_worker.mjs")
text = path.read_text()

text = text.replace(
'const CLAIM_SQL = readSql(`phase${SQL.phase}_claim_one.sql`);',
'const CLAIM_SQL = readSql(`phase${SQL.phase}_claim_one.sql`);\nconst MARK_SUCCESS_SQL = readSql(`phase${SQL.phase}_mark_success.sql`);'
)

insert_after = '''async function claimOnce(pool) {
  const runId = `run_${crypto.randomUUID()}`;
  const result = await pool.query(CLAIM_SQL, [runId, OWNER]);
  const task = result.rows?.[0];

  if (!task) {
    return null;
  }

  console.log("[worker] claimed task", {
    id: task.id,
    task_id: task.task_id,
    status: task.status,
    run_id: task.run_id,
    claimed_by: task.claimed_by
  });

  return task;
}
'''

replacement = insert_after + '''
async function completeSuccess(pool, task) {
  if (!task?.task_id) return null;

  const result = await pool.query(MARK_SUCCESS_SQL, [
    task.task_id,
    task.run_id ?? null,
    OWNER
  ]);

  const completed = result.rows?.[0] || null;

  if (completed) {
    console.log("[worker] completed task", {
      id: completed.id,
      task_id: completed.task_id,
      status: completed.status,
      run_id: completed.run_id,
      claimed_by: completed.claimed_by,
      completed_at: completed.completed_at
    });
  }

  return completed;
}
'''

text = text.replace(insert_after, replacement)

text = text.replace(
'      await claimOnce(pool);',
'      const task = await claimOnce(pool);\n      if (task) {\n        await completeSuccess(pool, task);\n      }'
)

path.write_text(text)
PY

node --check server/worker/phase26_task_worker.mjs
docker compose up -d --build worker

git add server/worker/phase26_task_worker.mjs
git commit -m "Phase 570: add success-only worker completion path"
git push
