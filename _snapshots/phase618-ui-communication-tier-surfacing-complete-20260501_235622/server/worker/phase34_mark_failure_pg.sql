-- Inputs: $1=task_id, $2=run_id, $3=actor
UPDATE tasks
SET status='failed',
    run_id=$2,
    actor=$3,
    error=COALESCE(error,'worker_mark_failure'),
    updated_at=NOW()
WHERE task_id=$1
RETURNING id, task_id, status, run_id, actor, error;
