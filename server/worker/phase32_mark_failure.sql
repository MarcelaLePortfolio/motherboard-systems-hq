WITH upd AS (
  UPDATE tasks
  SET
    attempts = attempts + 1,
    last_error = jsonb_build_object(
      'msg', $2::text,
      'ts',  (extract(epoch from now())*1000)::bigint
    ),
    status = CASE
      WHEN (attempts + 1) >= max_attempts THEN 'failed'
      ELSE 'queued'
    END,
    next_run_at = CASE
      WHEN (attempts + 1) >= max_attempts THEN NULL
      ELSE now() + make_interval(
        secs => LEAST(300, (2 * power(2, (attempts + 1) - 1))::int)
      )
    END,
    failed_at = CASE
      WHEN (attempts + 1) >= max_attempts THEN now()
      ELSE NULL
    END,
    locked_by = NULL,
    lock_expires_at = NULL,
    updated_at = now()
  WHERE id = $1
    AND status = 'running'
  RETURNING *
)
SELECT * FROM upd;
